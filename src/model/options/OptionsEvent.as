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
package model.options
{
	import flash.events.Event;
	
	import model.logger.Logger;

	public class OptionsEvent extends Event
	{
		
		public static const OPTIONS_FREQUENCY_CHANGED:String = "OPTIONS_FREQUENCY_CHANGED";
		public static const OPTIONS_SAVECYNINID_CHANGED:String = "OPTIONS_SAVECYNINID_CHANGED";
		public static const OPTIONS_SAVEPASSWORD_CHANGED:String = "OPTIONS_SAVEPASSWORD_CHANGED";
		public static const OPTIONS_AUTOSHOW_CHANGED:String = "OPTIONS_AUTOSHOW_CHANGED";
		public static const OPTIONS_COMPLETED:String = "OPTIONS_COMPLETED";
		public static const OPTIONS_SCREEN_CHANGED:String = "OPTIONS_SCREEN_CHANGED";
		public static const OPTIONS_SHOW_IN_TASKBAR_CHANGED:String = "OPTIONS_SHOW_IN_TASKBAR_CHANGED";
		public static const OPTIONS_ALWAYS_ON_TOP_CHANGED:String = "OPTIONS_ALWAYS_ON_TOP_CHANGED";
		
		public function OptionsEvent(type:String)
		{
			super(type, false, false);
		}
		override public function clone():Event
		{
			Logger.instance.log("Cloned Options event: " + this.type,Logger.SEVERITY_NORMAL);
			return new OptionsEvent(this.type);
		}
	}
}