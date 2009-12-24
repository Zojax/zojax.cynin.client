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
	import model.users.UserInfoEvent;
	import model.users.userinfo;
	
	public class UpdateItem extends BaseItem
	{
		[Bindable] public var description: String = "";
		[Bindable] public var allowedcomments: Boolean = false;
		[Bindable] public var commentcount: int = 0;
		[Bindable] public var canComment: Boolean = false;
		[Bindable] public var canEdit: Boolean = false;
		[Bindable] public var lastchangeaction: String = "";
		[Bindable] public var lastchangedate: Date = null;
		[Bindable] public var lastchangeperformer: String = "";


		//Value Objects and external (filled by other function calls) object collections
		//EXPECT these objects to be null valued to begin with!
		[Bindable] public var changeruservo:userinfo = null;  

		public function UpdateItem(iteminfo: Object = null)
		{
			if (iteminfo != null)
			{
				super(iteminfo);
				
				if (iteminfo is UpdateItem)
				{
					var item:UpdateItem = UpdateItem(iteminfo);
					description = item.description;
					allowedcomments	= item.allowedcomments;
					commentcount = item.commentcount;
					canComment = item.canComment;
					lastchangeaction = item.lastchangeaction;
					lastchangedate = item.lastchangedate;
					if (lastchangedate != null) lastchangedate = convertFromUTCDate(lastchangedate);
					lastchangeperformer = item.lastchangeperformer;
					canEdit = item.canEdit;
					
					
					if (item.changeruservo != null)
					{
						changeruservo = item.changeruservo;
					}
					else
					{
						if (lastchangeperformer != "")
						{
							if (updatemodel.instance.resolveAvatarDir(lastchangeperformer).exists)
							{
								changeruservo = new userinfo();
								changeruservo.username = lastchangeperformer;
								changeruservo.portrait_url = "file://" +  updatemodel.instance.resolveAvatarDir(lastchangeperformer).nativePath;
							}
							else 
							{
								updatemodel.instance.fetchUserinfo(lastchangeperformer);
							}
						}
					}
				}
				else
				{
					allowedcomments = iteminfo.allowedcomments;
					commentcount = iteminfo.commentcount;
					canComment = iteminfo.cancomment;
					lastchangeaction = iteminfo.lastchangeaction;
					lastchangeperformer = iteminfo.lastchangeperformer;
					canEdit = iteminfo.canedit;
					description = iteminfo.description;
					
					lastchangedate = iteminfo.lastchangedate;
					if (lastchangedate!=null)lastchangedate = convertFromUTCDate(lastchangedate);
	
					updatemodel.instance.addEventListener(UserInfoEvent.USERINFO_FETCHED,handleUserVOUpdate);
					if (lastchangeperformer != "")
					{
						if (updatemodel.instance.resolveAvatarDir(lastchangeperformer).exists)
						{
							changeruservo = new userinfo();
							changeruservo.username = lastchangeperformer;
							changeruservo.portrait_url = "file://" +  updatemodel.instance.resolveAvatarDir(lastchangeperformer).nativePath;
						}
						else 
						{
							updatemodel.instance.fetchUserinfo(lastchangeperformer);
						}
					}
				}

			}
		}

		override protected function handleUserVOUpdate(uservoev:UserInfoEvent):void
		{
			super.handleUserVOUpdate(uservoev);
			if (uservoev.uservo.username == lastchangeperformer  && (changeruservo == null || uservoev.IsLocallyFound == false))
			{
				Logger.instance.log("Updating changer uservo for: " + uservoev.uservo.username,Logger.SEVERITY_DEBUG);
				changeruservo = uservoev.uservo;
			}
		} 

		override public function toString(): String 
		{
            return "updateitem [id=" + id + ", uid=" + itemuid + ", title=" + title + ", description" + description 
            + ", portal_type=" + portal_type + ",modified=" +  modified + ", creator=" + creator 
            + ", allowedcomments=" + allowedcomments + ", commentcount=" + commentcount + ", absoluteurl=" + absoluteurl 
            + ", creatoruser=" + creatoruservo + ",lastchange=" + lastchangeaction + lastchangedate + lastchangeperformer 
            + ",[typevo=" + typevo + "]]"
		}
		
		
		public function get ActionTitle():String
		{
			switch (lastchangeaction)
			{
				case "created" :
					return "Created by " + lastchangeperformer;
					break;
			
				case "modified" :
					return "Edited by "  + lastchangeperformer;
					break;
			
				case "workflowstatechanged" :
					return "Workflowed by " + lastchangeperformer;
					break;
			
				case "commented" :
					return "Discussed by " + lastchangeperformer;
					break;
				default:
					return "Unknown by " + lastchangeperformer;
					break;
			}
		}
	}
}