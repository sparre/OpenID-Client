with Ada.Characters.Latin_1;
with Ada.Text_IO;

package body Logger is

   protected File is
      procedure Close;
      procedure Open (Name : in     String);
      procedure Put (Prefix, Message : in     String);
   private
      Log : Ada.Text_IO.File_Type;
   end File;

   protected body File is

      -------------
      --  Close  --
      -------------

      procedure Close
      is
      begin
         Ada.Text_IO.Close (File => Log);
      end Close;

      ------------
      --  Open  --
      ------------

      procedure Open
        (Name : in String)
      is
      begin
         Ada.Text_IO.Open (File => Log,
                           Name => Name,
                           Mode => Ada.Text_IO.Append_File);
      exception
         when others =>
            Ada.Text_IO.Create (File => Log,
                                Name => Name,
                                Mode => Ada.Text_IO.Out_File);
      end Open;

      -----------
      --  Put  --
      -----------

      procedure Put
        (Prefix, Message : in String)
      is
         Position : Positive := Message'First;
      begin
         Ada.Text_IO.Put (Log, " " & Prefix & " : ");
         loop
            loop
               exit when Position > Message'Last;
               exit when Message (Position) = Ada.Characters.Latin_1.LF;
               exit when Message (Position) = Ada.Characters.Latin_1.CR;

               Ada.Text_IO.Put (Log, Message (Position));
               Position := Position + 1;
            end loop;

            loop
               exit when Position > Message'Last;
               exit when Message (Position) /= Ada.Characters.Latin_1.LF and
                         Message (Position) /= Ada.Characters.Latin_1.CR;
               Position := Position + 1;
            end loop;

            Ada.Text_IO.New_Line (Log);
            exit when Position > Message'Last;
            Ada.Text_IO.Put (Log, "_" & Prefix & "_: ");
         end loop;
      end Put;
   end File;

   -------------
   --  Close  --
   -------------

   procedure Close is
   begin
      File.Close;
   end Close;

   -------------
   --  Debug  --
   -------------

   procedure Debug
     (Message : in String)
   is
   begin
      File.Put ("Debug", Message);
   end Debug;

   -------------
   --  Error  --
   -------------

   procedure Error
     (Message : in String)
   is
   begin
      File.Put ("Error", Message);
   end Error;

   ------------
   --  Info  --
   ------------

   procedure Info
     (Message : in String)
   is
   begin
      File.Put ("Info", Message);
   end Info;

   ------------
   --  Open  --
   ------------

   procedure Open
     (File_Name : in String)
   is
   begin
      File.Open (File_Name);
   end Open;

   ---------------
   --  Warning  --
   ---------------

   procedure Warning
     (Message : in String)
   is
   begin
      File.Put ("Warning", Message);
   end Warning;

end Logger;