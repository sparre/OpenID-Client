-----------------------------------------------------------------------
--  Util.Streams.Files -- File Stream utilities
--  Copyright (C) 2010, 2011 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------
with Ada.Strings.Unbounded;
with Util.Streams.Buffered;
with Ada.Characters.Handling;
with Ada.Calendar;
with GNAT.Calendar.Time_IO;
package Util.Streams.Texts is

   --  -----------------------
   --  Print stream
   --  -----------------------
   --  The <b>Print_Stream</b> is an output stream which provides helper methods
   --  for writing text streams.
   type Print_Stream is new Buffered.Buffered_Stream with private;
   type Print_Stream_Access is access all Print_Stream'Class;

   procedure Initialize (Stream : in out Print_Stream;
                         To     : in Output_Stream_Access);

   --  Write an integer on the stream.
   procedure Write (Stream : in out Print_Stream;
                    Item   : in Integer);

   --  Write an integer on the stream.
   procedure Write (Stream : in out Print_Stream;
                    Item   : in Long_Long_Integer);

   --  Write a string on the stream.
   overriding
   procedure Write (Stream : in out Print_Stream;
                    Item   : in Ada.Strings.Unbounded.Unbounded_String);

   --  Write a date on the stream.
   procedure Write (Stream : in out Print_Stream;
                    Item   : in Ada.Calendar.Time;
                    Format : in GNAT.Calendar.Time_IO.Picture_String
                    := GNAT.Calendar.Time_IO.ISO_Date);

   --  Get the output stream content as a string.
   function To_String (Stream : in Buffered.Buffered_Stream) return String;

private

   type Print_Stream is new Buffered.Buffered_Stream with null record;

end Util.Streams.Texts;