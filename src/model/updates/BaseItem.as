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
	import model.logger.Logger;
	import model.types.typeinfo;
	import model.types.typeinfoevent;
	import model.users.UserInfoEvent;
	import model.users.userinfo;
	
	public class BaseItem
	{
		[Bindable] public var id: String = "";
		[Bindable] public var itemuid: String = "";
		[Bindable] public var title: String = "";
		[Bindable] public var portal_type: String = "";
		[Bindable] public var modified: Date = null;
		[Bindable] public var creator: String = "";
		[Bindable] public var absoluteurl: String = "";

		//Value Objects and external (filled by other function calls) object collections
		//EXPECT these objects to be null valued to begin with!
		[Bindable] public var creatoruservo:userinfo = null;
		[Bindable] public var typevo:typeinfo = null;

		public function BaseItem(iteminfo: Object = null)
		{
			if (iteminfo != null)
			{
				id = iteminfo.id;
				itemuid = iteminfo.itemuid;
				title = iteminfo.title;
				portal_type = iteminfo.portal_type;
				modified = iteminfo.modified;
				if (modified!=null) modified = convertFromUTCDate(modified);
				creator = iteminfo.creator;
				absoluteurl = iteminfo.absoluteurl;

				updatemodel.instance.addEventListener(UserInfoEvent.USERINFO_FETCHED,handleUserVOUpdate);
				updatemodel.instance.addEventListener(typeinfoevent.TYPEADDED,handleTypeVOUpdate);
				if (creator!= "" )
				{
					if (updatemodel.instance.resolveAvatarDir(creator).exists)
					{
						creatoruservo = new userinfo();
						creatoruservo.username = creator;
						creatoruservo.portrait_url = "file://" +  updatemodel.instance.resolveAvatarDir(creator).nativePath;
					}
					else 
					{
						updatemodel.instance.fetchUserinfo(creator);
					}
				} 
				if (portal_type != "") updatemodel.instance.fetchTypeinfo(portal_type);
			}
		}

		protected function handleUserVOUpdate(uservoev:UserInfoEvent):void
		{
			if (uservoev.uservo.username == creator && (creatoruservo == null || uservoev.IsLocallyFound == false))
			{
				Logger.instance.log("Updating creator uservo for: " + uservoev.uservo.username,Logger.SEVERITY_DEBUG);
				creatoruservo = uservoev.uservo;
			}
		} 

		private function handleTypeVOUpdate(typevoev:typeinfoevent):void
		{
			if (typevoev.typevo.typename == portal_type && (typevo == null || typevoev.IsLocalOnlyFetch == false))
			{
				typevo = typevoev.typevo;
			}
		} 
		

		public function toString(): String 
		{
            return "BaseItem [id=" + id + ", uid=" + itemuid + ", title=" + title + ", portal_type=" + portal_type 
            + ",modified=" +  modified + ", creator=" + creator  
            + ", absoluteurl=" + absoluteurl + ", creatoruser=" 
            + creatoruservo 
            + ",[typevo=" + typevo + "]]"
		}
		static public function convertFromUTCDate(origDate:Date):Date
		{
			var newd:Date = new Date();
			newd.setTime(Date.UTC(origDate.fullYear,origDate.month,origDate.date,origDate.hours,origDate.minutes,origDate.seconds,origDate.milliseconds));
			return newd;
		}
	}
}