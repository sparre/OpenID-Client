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

with AWS.Response;
with AWS.Status;

package AWS.OpenID.Error_Messages is

   function Authentication_Failed
     (Request : in AWS.Status.Data)
     return AWS.Response.Data;
   --  TODO: write comment

   function Invalid_End_Point
     (Request : in AWS.Status.Data)
      return AWS.Response.Data;
   --  TODO: write comment

   function Invalid_URL
     (Request : in AWS.Status.Data)
      return AWS.Response.Data;
   --  TODO: write comment

   function Provider_Off_Line
     (Request : in AWS.Status.Data)
      return AWS.Response.Data;
   --  TODO: write comment

end AWS.OpenID.Error_Messages;
