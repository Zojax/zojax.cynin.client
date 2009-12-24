/*
	Copyright (c) 2008 Narciso Jaramillo
	All rights reserved.

	Redistribution and use in source and binary forms, with or without 
	modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in the 
      documentation and/or other materials provided with the distribution.
    * Neither the name of Narciso Jaramillo nor the names of other 
      contributors may be used to endorse or promote products derived from 
      this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
	USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
###############################################################################
#cyn.in is an open source Collaborative Knowledge Management Appliance that 
#enables teams to seamlessly work together on files, documents and content in 
#a secure central environment.
#
#cyn.in v2 an open source appliance is distributed under the GPL v3 license 
#along with commercial support options.
#
#cyn.in is a Cynapse Invention.
#
#Copyright (C) 2008 Cynapse India Pvt. Ltd.
#
#This program is free software: you can redistribute it and/or modify it under
#the terms of the GNU General Public License as published by the Free Software 
#Foundation, either version 3 of the License, or any later version and observe 
#the Additional Terms applicable to this program and must display appropriate 
#legal notices. In accordance with Section 7(b) of the GNU General Public 
#License version 3, these Appropriate Legal Notices must retain the display of 
#the "Powered by cyn.in" AND "A Cynapse Invention" logos. You should have 
#received a copy of the detailed Additional Terms License with this program.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of 
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
#Public License for more details.
#
#You should have received a copy of the GNU General Public License along with 
#this program.  If not, see <http://www.gnu.org/licenses/>.
#
#You can contact Cynapse at support@cynapse.com with any problems with cyn.in. 
#For any queries regarding the licensing, please send your mails to 
# legal@cynapse.com
#
#You can also contact Cynapse at:
#802, Building No. 1,
#Dheeraj Sagar, Malad(W)
#Mumbai-400064, India
###############################################################################
*/
package model.logger
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	
	/**
	 * Class that logs messages to a log file and/or the debug console.
	 * The log file lives in the user's documents folder (~/Documents or My Documents), in the Snackr subfolder.
	 */
	public class Logger extends EventDispatcher
	{
		/** 
		 * Severity for messages that should only be output to the debug console. (These will be output
		 * to the log file as well if running under ADL.)
		 */
		static public const SEVERITY_DEBUG: Number = -5;
		
		/**
		 * Severity for messages that should be output to both the debug console and the log file.
		 */
		static public const SEVERITY_NORMAL: Number = 0;
		
		/**
		 * Severity for messages that should be output to the debug console, the log file, and a UI warning.
		 */
		static public const SEVERITY_SERIOUS: Number = 5;
		
		/**
		 * Singleton instance of the logger.
		 */
		static private var _logger: Logger = new Logger();
		
		/**
		 * Returns the singleton logger instance.
		 */
		static public function get instance(): Logger {
			return _logger;
		}

		/**
		 * Handle to the log file.
		 */
		private var _logFile: File = null;
		
		/**
		 * Sets up the log file.
		 */
		public function initialize(logFile: File): void {
			// TODO: should limit the log file size, or perhaps just always start a new log file on startup.
			_logFile = logFile;
		}
		
		/**
		 * Returns the log file.
		 */
		public function get logFile(): File {
			return _logFile;
		}
		
		/**
		 * Logs a message to the log file/debug console/user warning.
		 * @param message The message to log.
		 * @param severity How serious the message is, which determines what the message is written to. See the constants above.
		 */
		public function log(message: String, severity: Number = SEVERITY_NORMAL): void {
			if (severity >= SEVERITY_NORMAL) trace(message);
			
			// If we're running in the debug launcher, we log all messages to the log file.
			// Otherwise, we only log messages with severity normal or above.
			if ((Capabilities.isDebugger || severity >= SEVERITY_SERIOUS) && _logFile != null) {
				var stream: FileStream = new FileStream();
				try {
					stream.open(_logFile, FileMode.APPEND);
					stream.writeUTFBytes(new Date().toString() + ": " + message + "\n");
				}
				catch (e: Error) {
					// Probably can't log this to the log file...
					trace("Can't write to log file: " + e.message);
				}
				finally {
					stream.close();
				}
			}
			
			dispatchEvent(new LogEvent(message, severity));
		}
	}
}