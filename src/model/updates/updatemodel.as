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
  import com.ak33m.rpc.xmlrpc.XMLRPCObject;

  import flash.desktop.NativeApplication;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IEventDispatcher;
  import flash.events.TimerEvent;
  import flash.filesystem.File;
  import flash.net.URLRequestDefaults;
  import flash.utils.Timer;

  import model.comments.CommentEvent;
  import model.logger.Logger;
  import model.options.OptionsModel;
  import model.types.typeinfo;
  import model.types.typeinfoevent;
  import model.users.UserInfoEvent;
  import model.users.userinfo;
  import model.versions.UpdateVersionVO;
  import model.versions.VersionEvent;

  import mx.collections.ArrayCollection;
  import mx.collections.ItemResponder;
  import mx.collections.Sort;
  import mx.collections.SortField;
  import mx.rpc.AsyncToken;
  import mx.rpc.events.FaultEvent;
  import mx.rpc.events.ResultEvent;
  import mx.rpc.http.HTTPService;
  import mx.utils.Base64Encoder;

  import ui.controls.DownloadImage;
  import ui.controls.SearchEvent;


  public class updatemodel extends EventDispatcher
  {

    [Embed (source="assets/icons/edit_icon.png")]
    private static var EDIT_ICON:Class;

    [Embed (source="assets/icons/discussionitem_icon.png")]
    private static var DISCUSSIONITEM_ICON:Class;

    [Embed (source="assets/icons/workflow_icon.png")]
    private static var WORKFLOW_ICON:Class;

    private var _page: ArrayCollection = new ArrayCollection(new Array());
    private var _sortitems:Sort = new Sort();


    private var _username: String = "";
    private var _password: String = "";
    private var _LoggedIn:Boolean = false;
    private var _siteurl:String = "";
    private var _fetchQueue: ArrayCollection = new ArrayCollection();

    private var _pageNum:int = 1;
    private var _pageChanging:Boolean = true;
    [Bindable] public var _pageCount:int;
    [Bindable] public var _totalUpdateItems:uint;


    private var _searchPage: ArrayCollection = new ArrayCollection(new Array());
    private var _searchPageNum:int = 1;
    [Bindable] public var _searchPageCount:int = 1;
    private var _searchInProgress:Boolean = false;
    [Bindable] public var _searchCurrentTerm:String = "";
    private var _toSelectItemUID:String = "";

    [Bindable] public var SiteLogoUrl:String = "";
    [Bindable] public var SiteTitle:String = "";

    private var timUpdate:Timer = new Timer(StringConstants.DEFAULT_UPDATE_CHECK_FREQUENCY);

    public function get username():String
    {
      return _username;
    }
    public function set username(newusername:String):void
    {
      _username = newusername;
    }
    public function get password():String
    {
      return _password;
    }
    public function set password(newpassword:String):void
    {
      _password = newpassword;
    }

    public function get LoggedIn():Boolean
    {
      return _LoggedIn;
    }

    public function get CurrentPageItems():ArrayCollection
    {
      return _page;
    }
    public function get CurrentSearchItems():ArrayCollection
    {
      return _searchPage;
    }
    public function set LoggedIn(newval:Boolean):void
    {
      _LoggedIn = newval;
      handlePostLoginTasks();
    }
    [Bindable] public function get SiteURL():String
    {
      return _siteurl;
    }
    public function set SiteURL(newurl:String):void
    {
      var mungedurl:String = newurl
      if (mungedurl.lastIndexOf("/") < (mungedurl.length - 1) ) //User did not append the required last / in the site url so we add it manually
      {
        mungedurl += "/"
      }
      _siteurl = mungedurl;
    }

    [Bindable] public var StatusMessage:String = StringConstants.DEFAULT_STATUS_MESSAGE;
    private var _newStatusMessage:String = "";
    private var StatusWasSetAt: Date = null;

    private static var _update:updatemodel = new updatemodel();
    public static function get instance():updatemodel
    {
      return _update;
    }

    /** User info store
     * Stores user info and images in memory and in the future, in the db
     */
    public var _users: ArrayCollection = new ArrayCollection(new Array());


    public var _types: ArrayCollection = new ArrayCollection(new Array());

      private const USE_DEFAULT_AUTH:Boolean = false;

    /**
     * The Server XMLRPC proxy object that is used to make calls to the cyn.in site
     */
     public var _xserver:XMLRPCObject = new XMLRPCObject();

     private var _pagesize:int = 5;

     private var Downloader:DownloadImage = new DownloadImage();


     public function get PageSize():int
     {
       return _pagesize;
     }
     //winTileStack sets this after determining the number of items that can fit in one screen.
     public function set PageSize(newpagesize:int):void
     {
       _pagesize = newpagesize;
       CountPages();
       getRecentUpdates();
       Logger.instance.log("Pagesize is now: " + _pagesize);
     }
     private function handlePostLoginTasks():void
     {
       getStatusMessage();
     }
     private function CountPages():void
     {
       dispatchEvent(new PageEvent(PageEvent.PAGE_COUNTING));
      if (_totalUpdateItems > 0)
      {
        _pageCount = Math.ceil(_totalUpdateItems / PageSize )
        Logger.instance.log("Page count: " + _pageCount + " Item count: " + _totalUpdateItems);
      }
      else
      {
        _pageCount = 0;
        Logger.instance.log("Page count: " + _pageCount + " Item count: " + _totalUpdateItems);
      }

      dispatchEvent(new PageEvent(PageEvent.PAGE_COUNTED));

      //_xserver.getUpdateCount().addResponder(new ItemResponder(handlegetUpdateCountResponse, handlegetUpdateCountFault));
     }

     private var _selecteditem: UpdateItem = null;

     [Bindable] public function get selectedItem():UpdateItem
     {
       return _selecteditem;
     }
     public function set selectedItem(setValue:UpdateItem):void
     {
       _selecteditem = setValue;
       dispatchEvent( new updateitemevent( updateitemevent.SELECTED, setValue) );
     }

    private var _inCommentMode:Boolean = false;
    public function get InCommentingMode():Boolean
    {
      return _inCommentMode;
    }
    public function set InCommentingMode(newval:Boolean):void
    {
      _inCommentMode = newval;
      if (_inCommentMode == true)
      {
        dispatchEvent(new CommentEvent(CommentEvent.IN_COMMENTING_MODE));
      }
      else
      {
        dispatchEvent(new CommentEvent(CommentEvent.OUT_COMMENTING_MODE));
      }
    }


    /***
     * The update check timer object
     */
    public var _updatetimer:Timer

    public var imgDownload:DownloadImage = new DownloadImage();

    public function updatemodel(target:IEventDispatcher=null)
    {

      /* Set the sort field for the collection. */
      var modifiedsortfield: SortField = new SortField("lastchangedate");
      modifiedsortfield.descending = true;
      _sortitems.fields = [modifiedsortfield]
      _page.sort = _sortitems;
      _page.refresh();

      //DO NOT UNCOMMENT THE BELOW LINE in a production box, it deletes logon info!!
      //EncryptedLocalStore.reset();

          this.addEventListener(authevent.AUTH_FAILED,handleAuthFailed);
          this.addEventListener(authevent.AUTH_SUCCEEDED, handleAuthSucceeded);
          imgDownload.addEventListener(DownloadEvent.DOWNLOAD_COMPLETE_AVATAR,handleAvatarCached);
          imgDownload.addEventListener(DownloadEvent.DOWNLOAD_COMPLETE_TYPEICON,handleTypeIconCached);


          timUpdate.addEventListener(TimerEvent.TIMER,handleUpdateTimer);

          SetupLogin();
      super(target);
    }


    public function SetupLogin():void
    {

      SiteURL = OptionsModel.instance.SiteURL;
      username = OptionsModel.instance.Username;
      password = OptionsModel.instance.Password;

      if (SiteURL != "" && username != "" && password != "")
      {
        AttemptLogin();
      }
      else if (USE_DEFAULT_AUTH)
      {
        username = StringConstants.APP_DEFAULT_USERNAME;
        password = StringConstants.APP_DEFAULT_PASSWORD;
        SiteURL = StringConstants.APP_DEFAULT_SITEURL;

        AttemptLogin();
        }
      else
      {
        Logger.instance.log("Dispatching event: NEED_AUTH");
        dispatchEvent(new authevent(authevent.NEED_AUTH));
      }
    }

    public function AttemptLogin():void
    {
      if (SiteURL.substr(0,7) != "http://")
      {
        SiteURL = "http://" + SiteURL;
      }
      dispatchEvent(new authevent(authevent.AUTH_ATTEMPTING,"User provided account details"));
      Logger.instance.log("Attempting login to: " + SiteURL + ", with user: " + username);
      URLRequestDefaults.authenticate = false;
            var encoder : Base64Encoder = new Base64Encoder();
      encoder.encode(username + ":" + password);
      _xserver.endpoint = SiteURL;
      _xserver.destination = StringConstants.APP_SITE_ENDPOINT;
          _xserver.headers["Authorization"] = "Basic " + encoder.toString();
          _xserver.sayhello().addResponder(new ItemResponder(handleAuthCheckResponse, handleAuthCheckFault));
    }

    private function handleAuthCheckResponse(event: ResultEvent, token : AsyncToken = null): void
    {
      if (event.result.toString() == "Hello")
      {
        Logger.instance.log("Authenticated! Yaay!!!!",Logger.SEVERITY_NORMAL);
        dispatchEvent(new authevent(authevent.AUTH_SUCCEEDED));
      }
      else
      {
        Logger.instance.log("Authentication FAILED: " + event.result,Logger.SEVERITY_NORMAL);
        dispatchEvent(new authevent(authevent.AUTH_FAILED,event.result.toString()));
      }
    }
        private function handleAuthCheckFault(event:FaultEvent, token : AsyncToken = null):void
        {
            Logger.instance.log("Authentication faulted: " + event.message,Logger.SEVERITY_NORMAL);
            if (event.message != null)
        dispatchEvent(new authevent(authevent.AUTH_FAILED,event.message.toString()));
      else
        dispatchEvent(new authevent(authevent.AUTH_FAILED,null));
        }


        private function SaveLogin():void
        {
          if (OptionsModel.instance.SaveCynInID == true) OptionsModel.instance.StoreIDDetails(); else OptionsModel.instance.UnStoreIDDetails();
          if (OptionsModel.instance.SavePassword == true) OptionsModel.instance.StorePassword(); else OptionsModel.instance.UnStorePassword();
        }
    private function handleAuthSucceeded(event:authevent):void
    {
      _page.removeAll();
      CountPages();
      LoggedIn = true;
      SaveLogin();
      stopTimer();
      _updatetimer = null;
      startTimer();
      //SiteLogoUrl = SiteURL + "logo.jpg";
      getSiteTitle();
      getSiteLogo();
      _pageChanging = true;
      getRecentUpdates();
      Logger.instance.log("Started timer, getting Site Title.");
    }
    private function createTimer():void
    {
      _updatetimer = new Timer(OptionsModel.instance.UpdateFrequency * 1000);
      _updatetimer.addEventListener(TimerEvent.TIMER, handleUpdateCheckTimer);
    }
    private function startTimer():void
    {
      if (_updatetimer == null)
      {
        createTimer();
      }
      _updatetimer.delay = OptionsModel.instance.UpdateFrequency * 1000;
      _updatetimer.start();
    }
    private function stopTimer():void
    {
      if (_updatetimer != null)
      {
        _updatetimer.stop();
      }
    }
    private function handleAuthFailed(event:authevent):void
    {
      LoggedIn = false;
    }

    private function getSiteTitle():void
    {
      _xserver.getSiteTitle().addResponder(new ItemResponder(handleGetSiteTitleResponse, handlerFault));
    }
    private function getSiteLogo():void
    {
      _xserver.getSiteLogo().addResponder(new ItemResponder(handleGetSiteLogoResponse, handlerFault));
    }

    public function LogOut():void
    {
      stopTimer();
      clearSecurityVariables();
      LoggedIn = false;
      dispatchEvent(new authevent(authevent.AUTH_LOGGEDOUT,"Clicked log out button."));
    }

    public function clearSecurityVariables():void
    {
      if (OptionsModel.instance.SaveCynInID == false)
      {
        _updatetimer = null;
        selectedItem = null;
        SiteURL = "";
        username = "";
        password = "";
        _page.removeAll();
        _page.refresh();
        _users.removeAll();
        _users.refresh();
        _types.removeAll();
        _types.refresh();
        _searchCurrentTerm = "";
        _searchPage.removeAll();
        _searchPage.refresh();

        return;
      }
      if (OptionsModel.instance.SavePassword == false)
      {
        password = "";
      }
    }

    private function handlergetRecentUpdates(event: ResultEvent, token : AsyncToken = null): void
    {
      var totalItemCount:int = event.result.itemcount;
      _totalUpdateItems = totalItemCount;
      CountPages();
            var retArr:Array = event.result.itemlist as Array;
            for each (var o:Object in retArr)
            {
              var oitem:UpdateItem = new UpdateItem(o);
              addUpdateItem(oitem);
            }
      if (_pageChanging == true)
      {
        _pageChanging = false;
        dispatchEvent(new PageEvent(PageEvent.PAGE_CHANGED));
      }
      dispatchEvent(new PageEvent(PageEvent.GET_RECENT_UPDATES_COMPLETED));
    }

    public function get PageCount():int
    {
      return _pageCount;
    }


    private function handleAvatarCached(event:DownloadEvent):void
    {
      var uinfo:userinfo = event.object as userinfo;
      uinfo.portrait_url = "file://" + event.file.nativePath;
      addUserInfo(uinfo);
    }
    private function handleTypeIconCached(event:DownloadEvent):void
    {
      var tinfo:typeinfo = event.object as typeinfo;
      tinfo.typeiconurl = "file://" + event.file.nativePath;
      addTypeInfo(tinfo);
    }


    public function resolveAvatarDir(username:String):File
    {
      var b64:Base64Encoder = new Base64Encoder();
      b64.encode(SiteTitle);
      return stacker.cacheDir.resolvePath(b64.toString()).resolvePath(StringConstants.CACHEDIR_AVATAR).resolvePath(username);
    }
    public function resolveTypeIconDir(typename:String):File
    {
      var b64:Base64Encoder = new Base64Encoder();
      b64.encode(SiteTitle);
      return stacker.cacheDir.resolvePath(b64.toString()).resolvePath(StringConstants.CACHEDIR_TYPEICON).resolvePath(typename);
    }

    private function addToFetchQueue(itemid:String,eventToTrigger:Event=null):void
    {
      var fetchobj:FetchQueueObject = new FetchQueueObject(itemid,eventToTrigger);
      var fetchind:int = FetchQueueIndex(fetchobj);
      if (fetchind >= 0)
      {
        //Logger.instance.log("Not re-fetching userinfo for: " + userid + "because request is already queued.",Logger.SEVERITY_NORMAL);
        return;
      }
      _fetchQueue.addItem(fetchobj);
    }

    private function removeFromFetchQueue(itemid:String):void
    {
          var fetchvo:FetchQueueObject = new FetchQueueObject(itemid);
          var fqind:int = FetchQueueIndex(fetchvo);
          if (fqind >= 0)
          {
            _fetchQueue.removeItemAt(fqind);
            if (_fetchQueue.length == 0) dispatchEvent(new RegularEvent(RegularEvent.OBJECT_FETCH_QUEUE_EMPTY));
          }
          else
          {
            //Logger.instance.log("Could not dequeue fetch: " + itemid,Logger.SEVERITY_NORMAL);
          }
    }
    public function get FetchQueueLength():int
    {
      return _fetchQueue.length;
    }
    public function get DownloadCacheQueueLength():int
    {
      return imgDownload.QueueLength;
    }

    private function handlergetUserInfo(event: ResultEvent, token : AsyncToken = null): void
    {
            var oitem:userinfo = new userinfo(event.result);
            var filAvatar:File = resolveAvatarDir(oitem.username);
            if (filAvatar.exists != true)
            {
              imgDownload.SaveToFile(oitem.portrait_url,filAvatar,oitem,DownloadEvent.DOWNLOAD_COMPLETE_AVATAR);
            }
            else
            {
              oitem.portrait_url = "file://" + filAvatar.nativePath;
            addUserInfo(oitem);
            }
            removeFromFetchQueue(oitem.username);
    }

    private function handleGetSiteTitleResponse(event: ResultEvent, token : AsyncToken = null): void
    {
      SiteTitle = event.result.toString();
    }
    private function handleGetSiteLogoResponse(event: ResultEvent, token : AsyncToken = null): void
    {
      SiteLogoUrl = event.result.toString();
    }

    private function handlergetTypeInfo(event: ResultEvent, token : AsyncToken = null): void
    {
            Logger.instance.log("handlergetTypeInfo function!" ,Logger.SEVERITY_SERIOUS);

            var oitem:typeinfo = new typeinfo(event.result);

            var filTypeInfo:File = resolveTypeIconDir(oitem.typename);
            if (filTypeInfo.exists != true)
            {
              imgDownload.SaveToFile(oitem.typeiconurl,filTypeInfo,oitem,DownloadEvent.DOWNLOAD_COMPLETE_TYPEICON);
            }
            else
            {
              oitem.typeiconurl = "file://" + filTypeInfo.nativePath;
            addTypeInfo(oitem);
            }
            removeFromFetchQueue(oitem.typename);
    }


        private function handlerFault(event:FaultEvent, token : AsyncToken = null):void
        {
            Logger.instance.log("Could not connect to xmlrpc server (or something similar)!" + event.message,Logger.SEVERITY_SERIOUS);
        }


    private function FetchQueueIndex(fetchvo:FetchQueueObject):int
    {
      var retval:int = -1;
      for each (var fo:FetchQueueObject in _fetchQueue)
      {
        if (fo.fetchid == fetchvo.fetchid)
        {
          return _fetchQueue.getItemIndex(fo);
        }
      }
      return retval;
    }

    /** Cleanup function to be called by handlequit
     */
    public function dispose():void
    {
      if (_updatetimer != null)
      {
        stopTimer();
        _updatetimer = null;
      }
    }

    /**
     * Handles the timer that tells us when to check if there are new / updated items.
     */
    private function handleUpdateCheckTimer(event: TimerEvent): void
    {
      Logger.instance.log("Timer hit. Delay is: " + _updatetimer.delay,Logger.SEVERITY_NORMAL);
      getRecentUpdates();
    }

    public function getRecentUpdates():void
    {
      if (LoggedIn)
      {
        _xserver.getRecentUpdates(stacker.instanceStack.pagesize(false),PageNumber).addResponder(new ItemResponder(handlergetRecentUpdates, handlerFault));
      }
    }


    /*** Fetch userinfo for given userid by xmlrpc **/
    public function fetchUserinfo(userid:String,forceFetch:Boolean = false):void
    {
      var userind:int = UserAlreadyExistsById(userid);
      if (userind >= 0 && forceFetch == false)
      {
        //Logger.instance.log("Not re-fetching userinfo for: " + userid + "because request was not enforced.",Logger.SEVERITY_NORMAL);
        dispatchEvent(new UserInfoEvent(UserInfoEvent.USERINFO_FETCHED,_users.getItemAt(userind) as userinfo,true));
        return;
      }
      else // Userinfo was not already found or request was enforced
      {
        addToFetchQueue(userid);
        Logger.instance.log("Fetching userinfo: " + userid,Logger.SEVERITY_NORMAL);
        var tok:AsyncToken =   _xserver.getUserInfo(userid);
        tok.userid = userid;
        tok.addResponder(new ItemResponder(handlergetUserInfo, handleFetchUserInfoFault,tok));
      }
    }

    /*** Fetch typeinfo for given typename by xmlrpc **/
    public function fetchTypeinfo(typename:String,forceFetch:Boolean = false):void
    {
      var typeind:int = TypeAlreadyExistsById(typename);
      if (typeind >= 0 && forceFetch == false)
      {
        dispatchEvent(new typeinfoevent(typeinfoevent.TYPEADDED, _types.getItemAt(typeind) as typeinfo,true));
      }
      else
      {
        addToFetchQueue(typename);
        Logger.instance.log("Fetching typeinfo: " + typename, Logger.SEVERITY_NORMAL);
        _xserver.getTypeInfo(typename).addResponder(new ItemResponder(handlergetTypeInfo, handlerFault));
      }
    }


    private function RemoveOldestItemFromPage():void
    {
      var rItem:UpdateItem = UpdateItem(_page.getItemAt(_page.length - 1));
      _page.removeItemAt(_page.getItemIndex(rItem));
      dispatchEvent(new updateitemevent( updateitemevent.REMOVED,rItem));
    }

    public function addItemToPage(item:UpdateItem):void
    {
      if (_page.length >= _pagesize) //We'll remove the oldest item to accomodate the new item.
      {
        Logger.instance.log("Removing oldest item from pagestack");
        RemoveOldestItemFromPage();
      }
      if (item==selectedItem || _page.contains(item))
      {
        Logger.instance.log("Updating existing item's data: " + item.title);
        dispatchEvent(new updateitemevent(updateitemevent.UPDATED, item));
        return;
      }
      _page.addItem(item);
      _page.refresh();
      dispatchEvent(new updateitemevent(updateitemevent.ADDED, item));
    }

    public function SetStatusLocal(newstatus:String):void
    {
      if (newstatus == "") newstatus = StringConstants.DEFAULT_STATUS_MESSAGE;
      StatusMessage = newstatus;
      StatusWasSetAt = new Date();
      _newStatusMessage = "";
    }

    public function handleNewItem(item:UpdateItem):void
    {
      // A great place to have a central "new to page" handler.

      //Check if the item is of portaltype Status Message and if it's creator is same as logged in user AND the time the item was created is later than the time we set status last, update their statusmessage
      Logger.instance.log("New item: " + item.portal_type);
      if (item.portal_type == StringConstants.TYPE_STATUSMESSAGE && item.creator == username &&
      StatusWasSetAt != null && item.modified.getTime() > StatusWasSetAt.getTime()
      && (item.lastchangeaction == "created" || item.lastchangeaction == "modified"))
      {
        SetStatusLocal(item.title);
      }
    }
    public function handleUpdateItem(item:UpdateItem):void
    {
      // A great place to have a central "item updated" handler.
    }
    public function addUpdateItem(item: UpdateItem):void
    {
      var itemcheckresult:int = ItemAlreadyExists(item);
      if ( itemcheckresult == 0)
      {
        Logger.instance.log("Added new " + item.portal_type + " to _allitems: " + item.title );
        handleNewItem(item);
        addItemToPage(item);
      }
      else if (itemcheckresult == 1)
      {
        Logger.instance.log("Updating " + item.portal_type + " in _allitems: " + item.title );
        handleUpdateItem(item);
        var olditem:UpdateItem = GetItemByUID(item.itemuid);
        _page.removeItemAt(_page.getItemIndex(olditem));
        olditem = null;
        _page.addItem(item);
        _page.refresh();
        addItemToPage(item);
      }
      else if (itemcheckresult == -1)
      {
        Logger.instance.log("Discarding unupdated item: " + item.title,Logger.SEVERITY_DEBUG);
      }
      else if (itemcheckresult < -1)
      {
        Logger.instance.log("UPDATEITEM without LastChangeDate!!: " + item);
      }
    }
    public function addUserInfo(user: userinfo):void
    {
      var userind:int = UserAlreadyExists(user);

      if (userind < 0) //Add new user object if it doesn't exit
      {
        Logger.instance.log("Adding new userinfo: " + user, Logger.SEVERITY_DEBUG)
        _users.addItem(user);
      }
      else // Update user object since it already exists
      {
        Logger.instance.log("Updating existing userinfo: " + user + " at: " + userind, Logger.SEVERITY_DEBUG)
        _users.setItemAt(user,userind);
      }
      dispatchEvent(new UserInfoEvent(UserInfoEvent.USERINFO_FETCHED,user,false));
    }


    public function addTypeInfo(type: typeinfo):void
    {
      var typeind:int = TypeAlreadyExists(type);
      if (typeind < 0) //Add new type object if it doesn't exit
      {
        Logger.instance.log("Adding new typeinfo: " + typeind, Logger.SEVERITY_DEBUG)
        _types.addItem(type);
      }
      else // Update type object since it already exists
      {
        Logger.instance.log("Updating existing typeinfo: " + type + " at: " + typeind, Logger.SEVERITY_DEBUG)
        _types.setItemAt(type,typeind);
      }
      dispatchEvent(new typeinfoevent(typeinfoevent.TYPEADDED,type,true));
      //UpdateItemTypes(type);
    }



    private function ItemAlreadyExists(item:UpdateItem): int
    {
      for each (var i:UpdateItem in _page)
      {
        if (i.itemuid == item.itemuid)
        {
          if (i == null || i.lastchangedate == null || item.lastchangedate == null) return -2; //Item with no lastchangedate??
          if (i.lastchangedate.getTime() == item.lastchangedate.getTime())
          {
            return -1;
          }
          else
          {
            return 1;
          }
        }
      }
      return 0;
    }

    private function GetItemByUID(itemuid:String):UpdateItem
    {
      for each (var i:UpdateItem in _page)
      {
        if (i.itemuid == itemuid)
        {
            return i;
        }
      }
      return null;
    }

    /** Checks if user exists in the _users collection and if so returns the index else returns -1 **/
    private function UserAlreadyExists(user: userinfo):int
    {
      for each (var u:userinfo in _users)
      {
        if (u.username == user.username) return _users.getItemIndex(u);
      }
      return -1;
    }
    public function UserAlreadyExistsById(userid: String):int
    {
      for each (var u:userinfo in _users)
      {
        if (u.username == userid)
        {
          //Logger.instance.log("Usermatch found: " + userid,Logger.SEVERITY_NORMAL);
          return _users.getItemIndex(u);
        }
      }
      return -1;
    }
    private function TypeAlreadyExists(type: typeinfo):int
    {
      for each (var t:typeinfo in _types)
      {
        if (t.typename == type.typename) return _types.getItemIndex(t);
      }
      return -1;
    }
    private function TypeAlreadyExistsById(typename: String):int
    {
      for each (var t:typeinfo in _types)
      {
        if (t.typename == typename)
        {
          //Logger.instance.log("Typematch found: " + typename,Logger.SEVERITY_NORMAL);
          return _types.getItemIndex(t);
        }
      }
      return -1;
    }

    public function getItemIndex(item: BaseItem):int
    {
      return ( _page.getItemIndex(item) );
    }

    public function fetchItemByUID(item_uid:String):void
    {
      _xserver.refreshUpdateItem(item_uid).addResponder(new ItemResponder(handleRefreshItem, handlerFault));
    }

    private function handleRefreshItem(event: ResultEvent, token : AsyncToken = null): void
    {
            var uitem:UpdateItem = new UpdateItem(event.result);
            //addUpdateItem(uitem);  //Removed for handling search results
          if(uitem.itemuid == _toSelectItemUID)
          {
            selectedItem = uitem;
          }
    }


    public function selectItemByUID(item_uid:String):void
    {
      var toSelect:UpdateItem =GetItemByUID(item_uid)
      if (toSelect == null)
      {
        _toSelectItemUID = item_uid;
        fetchItemByUID(item_uid);
      }
      else
      {
        selectedItem = toSelect;
      }
    }

    public function removeItemByUID(remove_uid:String):Boolean
    {
      var removeind:int = -1;
            var wasSelectedItem:Boolean = false;

      for each (var item:UpdateItem in _page)
      {
        if (item.itemuid == remove_uid)
        {
          removeind = getItemIndex(item);
          break;
        }
      }
          if (selectedItem != null && selectedItem.itemuid == remove_uid)
          {
            wasSelectedItem = true;
        selectedItem = null;
          }
      if (removeind > -1) //Item and it's index was found
      {
        _page.removeItemAt(removeind);
      }
      return wasSelectedItem;
    }

    public function get PageChanging():Boolean
    {
      return _pageChanging;
    }

    [Bindable] public function get PageNumber():int
    {
      return _pageNum;
    }
    public function set PageNumber(pagenum:int):void
    {
      removeAllExceptSelected();
      _pageChanging = true;
      _pageNum = pagenum;
      dispatchEvent(new PageEvent(PageEvent.PAGE_CHANGING));

      if (_searchCurrentTerm == "")
      {
        Logger.instance.log("Setting Recent page number to: " + pagenum);
        getRecentUpdates();
      }
      else
      {
        Logger.instance.log("Setting Search page number to: " + pagenum);
        getSearch();
      }
    }
    private function removeAllExceptSelected():void
    {
//			if (selectedItem != null)
//			{
//				for each (var uItem:UpdateItem in _page)
//				{
//					if (uItem != selectedItem)
//					{
//						_page.removeItemAt(_page.getItemIndex(uItem));
//					}
//				}
//			}
//			else
//			{
        _page.removeAll();
//			}
    }
    public function incrementPageNumber():void
    {
      if (PageNumber < _pageCount ) PageNumber = PageNumber + 1;
    }
    public function decrementPageNumber():void
    {
      if (PageNumber > 1 && _pageCount > 0 ) PageNumber = PageNumber - 1;
    }


    public function cancelSearch():void
    {
      _searchCurrentTerm = "";
      _searchInProgress = false;
      dispatchEvent(new SearchEvent(SearchEvent.SEARCH_CANCELED));
      startTimer();
      //getRecentUpdates(); // We already have the last list. There's no need to immediately refresh - we'll let the timer do it's thing instead.
      Logger.instance.log("Search canceled.",Logger.SEVERITY_NORMAL);
    }
    public function changeSearch(newterm:String=""):void
    {
      if (newterm != "") _searchCurrentTerm = newterm; //Set the newterm only if one *was* passed
      stopTimer();
      if (!_searchInProgress)
      {
              _pageNum = 1;
        dispatchEvent(new SearchEvent(SearchEvent.SEARCH_CHANGE,_searchCurrentTerm));
        getSearch(_searchCurrentTerm);
      }
    }
    public function searchBeginTyping():void
    {
      dispatchEvent(new SearchEvent(SearchEvent.SEARCH_BEGIN_TYPING));
    }
    public function getSearch(newterm:String=""):void
    {
      if (newterm == "") newterm = _searchCurrentTerm; //Set the newterm if one was *not* passed
      newterm = starify(newterm);
      _searchCurrentTerm = newterm;
      _searchInProgress = true;
      _xserver.search( newterm,stacker.instanceStack.pagesize(true),PageNumber).addResponder(new ItemResponder(handleSearchResponse, handleSearchFault));
    }
    private function handleSearchResponse(event: ResultEvent, token : AsyncToken = null): void
    {
      Logger.instance.log("Got Search Response",Logger.SEVERITY_NORMAL);
      if (_searchInProgress)
      {
        _searchPage.removeAll();
        var term:String = event.result.term;
        var itemCount:int = event.result.itemcount; Logger.instance.log("Items: " + itemCount,Logger.SEVERITY_NORMAL);
              var retArr:Array = event.result.itemlist as Array;
              _pageCount = Math.ceil(itemCount / stacker.instanceStack.pagesize(true) )
              _totalUpdateItems = itemCount;
              for each (var o:Object in retArr)
              {
                var oitem:SearchItem = new SearchItem(o);
                _searchPage.addItem(oitem);
              }
              dispatchEvent(new SearchEvent(SearchEvent.SEARCH_RESULTS_ARRIVED,term));
              _searchInProgress = false;
              Logger.instance.log("Current Search:+ " + _searchCurrentTerm + ", returned=" + term);
              if (_searchCurrentTerm != term)
              {
                changeSearch();
              }
      }
    }
    private function handleSearchFault(event: FaultEvent, token : AsyncToken = null): void
    {
      Logger.instance.log("Could not get search results:" + event.message);
    }
    private function handleFetchUserInfoFault(event: FaultEvent, token : AsyncToken = null): void
    {
      removeFromFetchQueue(token.userid);
      Logger.instance.log(event.toString());
    }
    private function starify(term:String):String
    {
      var retterm:String = term;
      if (retterm.charAt(retterm.length - 1) != "*")
      {
        retterm =  retterm + "*";
      }
      if (retterm.charAt(0) != "*")
      {
        retterm = "*" + retterm;
      }
      return retterm;
    }
    private function unstarify(term:String):String
    {
      var retterm:String = term;
      if (retterm.charAt(retterm.length) == "*")
      {
        retterm =  retterm.substr(0,retterm.length - 1); //strip ending *
      }
      if (retterm.charAt(0) == "*")
      {
        retterm = retterm.substr(1,retterm.length - 1); //strip beginning *
      }
      return retterm;
    }
    public function StartUpdateCheck():void
    {
      timUpdate.start();

      //Debug only:
      handleUpdateTimer(null);
    }
    public function StopUpdateCheck():void
    {
      timUpdate.stop();
    }
    public function checkForUpdate():void
    {
      var httpreq:HTTPService = new HTTPService();
      httpreq.url = StringConstants.APP_UPDATE_CHECK_URL;
      //httpreq.resultFormat = "e4x";
      httpreq.addEventListener(ResultEvent.RESULT,handleUpdateCheckResponse);
      httpreq.addEventListener(FaultEvent.FAULT,handleUpdateCheckFault);
      httpreq.send();
    }
    private function handleUpdateTimer(event:TimerEvent):void
    {
      checkForUpdate();
    }
    private function handleUpdateCheckResponse(event:ResultEvent):void
    {
      Logger.instance.log("Update check SUCCESS. Available version: " + event.result.stackerversions.current.versionstring);
      var uvo:UpdateVersionVO = new UpdateVersionVO(event.result.stackerversions.current);
      namespace airAppNS = "http://ns.adobe.com/air/application/1.5";
      use namespace airAppNS;
      var appversion:String = NativeApplication.nativeApplication.applicationDescriptor.version;
      if (appversion != uvo.Version )
      {
        dispatchEvent(new VersionEvent(VersionEvent.VERSION_NEW_AVAILABLE,uvo));
      }
      else
      {
        dispatchEvent(new VersionEvent(VersionEvent.VERSION_NEW_NOT_AVAILABLE,uvo));
      }
    }
    private function handleUpdateCheckFault(event:FaultEvent):void
    {
      Logger.instance.log("Update check FAILED!: " + event.message);
    }
    public function getStatusMessage():void
    {
      if (LoggedIn)
      {
        _xserver.getStatusMessage().addResponder(new ItemResponder(handleStatusMessageResponse, handleStatusMessageFault));
      }
    }
    public function setStatusMessage(m:String):void
    {
      _pageChanging = true;
      selectedItem = null;
      _page.removeAll();
      dispatchEvent(new PageEvent(PageEvent.PAGE_CHANGING));
      _newStatusMessage = m;
      _xserver.setStatusMessage(m).addResponder(new ItemResponder(handleSetStatusMessageResponse, handleSetStatusMessageFault));
    }
    private function handleStatusMessageResponse(event: ResultEvent, token : AsyncToken = null): void
    {
      Logger.instance.log("Got Current Status Response: " + event.result);
      SetStatusLocal(event.result.toString());
    }
    private function handleStatusMessageFault(event: FaultEvent, token : AsyncToken = null): void
    {
      SetStatusLocal("");
      Logger.instance.log("Could not get Current Status:" + event.message,Logger.SEVERITY_SERIOUS);
    }
    private function handleSetStatusMessageResponse(event: ResultEvent, token : AsyncToken = null): void
    {
      Logger.instance.log("Status Message set successfully.");
      SetStatusLocal(_newStatusMessage);
      getRecentUpdates();
    }
    private function handleSetStatusMessageFault(event: FaultEvent, token : AsyncToken = null): void
    {
      Logger.instance.log("Could not set Current Status:" + event.message,Logger.SEVERITY_SERIOUS);
    }

    public function clearCache():void
    {
      var filArr:Array = stacker.cacheDir.getDirectoryListing();
      var i:int;
      for (i=0;i<filArr.length; i++)
      {
        var file:File = filArr[i];
        if (file.isDirectory)
          file.deleteDirectory(true);
        else
          file.deleteFile();
      }
      stacker.instanceStack.emptyStack();
      refresh();
    }
    public function refresh():void
    {
      _pageChanging = true;
      _page.removeAll();
      _searchPage.removeAll();
      _users.removeAll();
      _types.removeAll();
      selectedItem = null;
      PageNumber=1;
      getRecentUpdates();
    }
    public function getImageForAction(action:String):Class
    {
      switch (action)
      {
        case "created" :
          return EDIT_ICON;
          break;

        case "modified" :
          return EDIT_ICON;
          break;

        case "workflowstatechanged" :
          return WORKFLOW_ICON;
          break;

        case "commented" :
          return DISCUSSIONITEM_ICON;
          break;
        default:
          return EDIT_ICON;
          break;
      }
    }
  }
}