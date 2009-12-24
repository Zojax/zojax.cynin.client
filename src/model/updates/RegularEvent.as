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
	import flash.events.Event;

	public class RegularEvent extends Event
	{
		
		static public const IMAGE_DOWNLOAD_QUEUE_EMPTY: String = "IMAGE_DOWNLOAD_QUEUE_EMPTY";
		static public const OBJECT_FETCH_QUEUE_EMPTY: String = "OBJECT_FETCH_QUEUE_EMPTY";
		static public const TILE_LOADED: String = "TILE_LOADED";
		static public const SWITCH_TO_STATUS_INPUT: String = "SWITCH_TO_STATUS_INPUT";
		static public const STATUS_INPUTTED: String = "STATUS_INPUTTED";
		
		
		public function RegularEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event
		{
			return new RegularEvent(this.type);
		}
		
	}
}