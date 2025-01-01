package com.presenter.shared
{
	import com.model.chat.ChatChannelVO;
	import com.model.chat.ChatPanelVO;
	import com.model.motd.MotDVO;
	import com.model.player.PlayerVO;
	import com.presenter.IImperiumPresenter;

	import flash.utils.Dictionary;

	public interface IChatPresenter extends IImperiumPresenter
	{
		function sendChatMessage( message:String ):void;
		function gotoCoords( x:int, y:int, sector:String ):void;

		function getChannelColorFromChannelID( channelID:int ):uint;
		function getActiveChannels():Dictionary;

		function requestPlayer( id:String, name:String = '' ):void;

		function blockOrUnblockPlayer( id:String ):void;
		function isBlocked( id:String ):Boolean;
		function mutePlayer( id:String ):void;
		function isMuted( id:String ):Boolean;
		function getPanelLogs( panelID:uint ):String;
		function getPlayer( id:String ):PlayerVO;

		function addChatListener( callback:Function ):void;
		function removeChatListener( callback:Function ):void;
		function addOnActiveChannelUpdatedListener( callback:Function ):void;
		function removeOnActiveChannelUpdatedListener( callback:Function ):void;
		function addOnDefaultChannelLoadedListener( callback:Function ):void;
		function removeOnDefaultChannelLoadedListener( callback:Function ):void;
		function addOnDefaultChannelUpdatedListener( callback:Function ):void;
		function removeOnDefaultChannelUpdatedListener( callback:Function ):void;
		function addMotDUpdatedListener( callback:Function ):void;
		function removeMotDUpdatedListener( callback:Function ):void;
		function addOnPlayerVOAddedListener( callback:Function ):void;
		function removeOnPlayerVOAddedListener( callback:Function ):void;

		function get chatHasFocus():Boolean;
		function get defaultChannel():ChatChannelVO;
		function get blockedUsers():Vector.<String>;
		function get chatPanels():Vector.<ChatPanelVO>;
		function get motdMessages():Vector.<MotDVO>;

		function set defaultChannel( newDefault:ChatChannelVO ):void;
		function set chatHasFocus( value:Boolean ):void;
	}
}
