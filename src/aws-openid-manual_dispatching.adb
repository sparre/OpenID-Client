-------------------------------------------------------------------------------
--                                                                           --
--                      Copyright (C) 2012-, AdaHeads K/S                    --
--                                                                           --
--  This is free software;  you can redistribute it and/or modify it         --
--  under terms of the  GNU General Public License  as published by the      --
--  Free Software  Foundation;  either version 3,  or (at your  option) any  --
--  later version. This library is distributed in the hope that it will be   --
--  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of  --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     --
--  You should have received a copy of the GNU General Public License and    --
--  a copy of the GCC Runtime Library Exception along with this program;     --
--  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
--  <http://www.gnu.org/licenses/>.                                          --
--                                                                           --
-------------------------------------------------------------------------------

with Ada.Exceptions;
with Ada.Strings.Unbounded;

with AWS.OpenID.Association_Database;
with AWS.OpenID.Authentication_Database;
with AWS.OpenID.Log;

private with AWS.OpenID.Security;

package body AWS.OpenID.Manual_Dispatching is

   Realm : Security.Manager;

   package body Log_In is

      ---------------
      --  Service  --
      ---------------

      function Service
        (Request : in AWS.Status.Data)
         return AWS.Response.Data
      is
         use Ada.Exceptions;

         End_Point   : Security.End_Point;
         Association : Security.Association;
      begin
         if Authentication_Database.Is_Authenticated (Request) then
            return AWS.Response.URL (Logged_In.URI);
         end if;

         declare
            Provider : constant String
              := AWS.Status.Parameters (Request).Get (Provider_Parameter_Name);
         begin
            Security.Discover (Realm  => Realm,
                               Name   => Provider,
                               Result => End_Point);
         exception
            when Constraint_Error =>
               return Invalid_URL (Request);
            when Security.Invalid_End_Point =>
               return Invalid_End_Point (Request);
            when Security.Service_Error =>
               return Provider_Offline (Request);
         end;

         Security.Associate (Realm  => Realm,
                             OP     => End_Point,
                             Result => Association);
         Association_Database.Insert (Association);

         declare
            URL : constant String := Security.Get_Authentication_URL
              (Realm => Realm,
               OP    => End_Point,
               Assoc => Association);
         begin
            return AWS.Response.URL (URL);
         end;
      exception
         when E : others =>
            Log.Error
              ("Exception in " &
                 "AWS.OpenID.Manual_Dispatching.Log_In.Service: " &
                 Exception_Information (E));

            if Authentication_Database.Is_Authenticated (Request) then
               --  For some odd reason we've got both an exception and the user
               --  is authenticated, which should never happen, so we do a
               --  pre-cautionary log out of the user. Better safe than sorry.
               return Log_Out.Service (Request);
            else
               return Authentication_Failed (Request);
            end if;
      end Service;

   end Log_In;

   package body Validate is

      ---------------
      --  Service  --
      ---------------

      function Service
        (Request : in AWS.Status.Data)
         return AWS.Response.Data
      is
         use Ada.Exceptions;

         Handle         : Ada.Strings.Unbounded.Unbounded_String;
         Association    : Security.Association;
         Authentication : Security.Authentication;
      begin
         Handle := Security.Handle (Request);

         if not Association_Database.Has (Handle) then
            return Authentication_Failed (Request);
         end if;

         Association := Association_Database.Look_Up (Handle);
         Authentication := Security.Verify (Realm   => Realm,
                                            Assoc   => Association,
                                            Request => Request);

         if Security.Authenticated (Authentication) then
            return Result : AWS.Response.Data do
               Result :=
                 AWS.Response.URL (Protocol & Host_Name & Logged_In.URI);

               Authentication_Database.Register_Identity
                 (Source   => Authentication,
                  Request  => Request,
                  Response => Result);
            end return;
         else
            return Authentication_Failed (Request);
         end if;
      exception
         when E : others =>
            Log.Error
              ("Exception in " &
                 "AWS.OpenID.Manual_Dispatching.Validate.Service: " &
                 Exception_Information (E));

            if Authentication_Database.Is_Authenticated (Request) then
               --  For some odd reason we've got both an exception and the user
               --  is authenticated, which should never happen, so we do a
               --  pre-cautionary log out of the user. Better safe than sorry.
               return Log_Out.Service (Request);
            else
               return Authentication_Failed (Request);
            end if;
      end Service;

   end Validate;

   package body Log_Out is

      ---------------
      --  Service  --
      ---------------

      function Service
        (Request : in AWS.Status.Data)
         return AWS.Response.Data
      is
         use Ada.Exceptions;

         Response : AWS.Response.Data;
      begin
         Response :=
           AWS.Response.URL (Protocol & Host_Name & Logged_Out.URI);

         Authentication_Database.Delete_Identity
           (Request  => Request,
            Response => Response);

         return Response;
      exception
         when E : others =>
            Log.Error
              ("Exception in " &
                 "AWS.OpenID.Manual_Dispatching.Log_Out.Service: " &
                 Exception_Information (E));

            if Authentication_Database.Is_Authenticated (Request) then
               --  This is really bad.
               Log.Error
                 ("AWS.OpenID.Manual_Dispatching.Log_Out.Service cannot " &
                    "log user out");
               raise;
            else
               return Authentication_Failed (Request);
            end if;
      end Service;

   end Log_Out;

   ------------------------
   --  Authenticated_As  --
   ------------------------

   function Authenticated_As
     (Request : in AWS.Status.Data)
      return String
   is
   begin
      return Authentication_Database.Identity (Request);
   end Authenticated_As;

   ------------------------
   --  Is_Authenticated  --
   ------------------------

   function Is_Authenticated
     (Request : in AWS.Status.Data)
      return Boolean
   is
   begin
      return Authentication_Database.Is_Authenticated (Request);
   end Is_Authenticated;

begin

   Security.Initialize (Realm     => Realm,
                        Domain    => Protocol & Host_Name,
                        Return_To => Return_To_Page);

end AWS.OpenID.Manual_Dispatching;
