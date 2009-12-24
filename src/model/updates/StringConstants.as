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
package model.updates
{
	public class StringConstants
	{
		//Encrypted local store string constants
		public static const ELS_LAST_AUTH_SUCCEEDED:String ="LastAuthSuccess";
		public static const ELS_USERNAME:String ="username";
		public static const ELS_PASSWORD:String ="password";
		public static const ELS_SITEURL:String ="siteurl";
		public static const ELS_START_ON_LOGON:String = "autostartuponlogin";
		public static const ELS_UPDATE_FREQUENCY:String = "updatefrequency";
		public static const ELS_SAVE_CYNIN_ID:String = "ELS_SAVE_CYNIN_ID";
		public static const ELS_SAVE_PASSWORD:String = "ELS_SAVE_PASSWORD";
		public static const ELS_AUTO_SHOW:String = "ELS_AUTO_SHOW";
		public static const ELS_SCREEN_INDEX:String = "ELS_SCREEN_INDEX";
		public static const ELS_ALWAYS_ON_TOP:String = "ELS_ALWAYS_ON_TOP";
		public static const ELS_SHOW_IN_TASKBAR:String = "ELS_SHOW_IN_TASKBAR";
		

		//App logic string constants
		public static const APP_NAME:String = "cyn.in Desktop";
		public static const APP_DEFAULT_USERNAME:String ="dhiraj";
		public static const APP_DEFAULT_PASSWORD:String ="secret";
		public static const APP_DEFAULT_SITEURL:String ="http://dkg:8000/intranet/";
		public static const APP_SITE_ENDPOINT:String="stacker";
		public static const APP_UPDATE_CHECK_URL:String="http://cyn.in/stackerversion.php";
		

		//DEFAULTS
		public static const DEFAULT_FREQUENCY:Number = 60; //Default Update frequency
		public static const DEFAULT_SAVE_ID:Boolean = true; //Defaulty save id details
		public static const DEFAULT_SAVE_PASSWORD:Boolean = true; //Defaultly save the user's password
		public static const DEFAULT_STATUS_MESSAGE:String = "What are you doing?"; //Default status message
		public static const DEFAULT_AUTO_SHOW:Boolean = true; //Default for show on new activity
		public static const DEFAULT_SELECT_TILE_DURATION:int = 500; //Default timeout to select tile in
		public static const DEFAULT_UPDATE_CHECK_FREQUENCY:int = 1000 * 60 * 60 * 1; //Default update frequency for 1 hour
		public static const DEFAULT_ALWAYS_ON_TOP:Boolean = true; //Defaultly save the user's password
		public static const DEFAULT_SHOW_IN_TASKBAR:Boolean = true; //Defaultly save the user's password
		public static const MINIMUM_FREQUENCY:Number = 10; //Default Update frequency
		public static const MINIMUM_PAGESIZE:Number = 4; //Minimum number of items to show
		public static const UPDATE_TILE_SIZE:Number = 48; //Height of update tiles
		public static const SEARCH_TILE_SIZE:Number = 48; //Height of search tiles
		public static const CACHEDIR_AVATAR:String = "avatars"; //Cache directory name for avatars, used under main cache directory
		public static const CACHEDIR_TYPEICON:String = "typeicons"; //Cache directory name type icons, used under main cache directory
		
		//ITEM TYPES
		public static const TYPE_STATUSMESSAGE:String = "StatuslogItem";
	}
}