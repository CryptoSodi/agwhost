package com.ui.modal.information
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.presenter.shared.IUIPresenter;
	import com.ui.UIFactory;
	
	import com.model.player.CurrentUser;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.button.BitmapButton;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	
	import com.service.ExternalInterfaceAPI;
	
	import org.shared.ObjectPool;
	
	public class GuestRestrictionView extends View
	{
		private var _bg:DefaultWindowBG;
		private var _info:Label;
		
		private var _holder:Sprite;
		
		private var _titleText:String                     = 'CodeString.GuestRestriction.Title';
		
		private var _infoText:String             = 'CodeString.GuestRestriction.Info'; 
		
		private var _continueBtn:BitmapButton;
		private var _registerBtn:BitmapButton;
		private var _continueText:String       = 'CodeString.GuestRestriction.ContinueBtn'; //Continue
		private var _registerText:String       = 'CodeString.GuestRestriction.RegisterBtn'; //Register
		
		[PostConstruct]
		override public function init():void
		{
			super.init();
			
			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(563, 200);
			_bg.addTitle(_titleText, 114);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);
			
			_info = new Label(20, 0xf0f0f0, 572, 25);
			_info.align = TextFormatAlign.CENTER;
			_info.setTextWithTokens(_infoText,null);
			_info.y = 90;
			
			_holder = new Sprite();
			_holder.x = 25;
			_holder.y = 53;
			
			_continueBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 160, 40, 100, 170, _continueText, LabelEnum.H1);
			addListener(_continueBtn, MouseEvent.CLICK, onContinue);
			_registerBtn = UIFactory.getButton(ButtonEnum.GREEN_A, 160, 40, 315, 170, _registerText, LabelEnum.H1);
			addListener(_registerBtn, MouseEvent.CLICK, onRegister);
			
			
			addChild(_bg);
			addChild(_holder);
			addChild(_info);
			addChild(_continueBtn);
			addChild(_registerBtn);
			
			addEffects();
			effectsIN();
		}
		
		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }
		
		private function onContinue( e:MouseEvent ):void
		{
			onClose();
		}
		private function onRegister( e:MouseEvent ):void
		{
			ExternalInterfaceAPI.registerGuest();
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			if (_bg)
				ObjectPool.give(_bg);
			
			_bg = null;
			
			if (_info)
				_info.destroy();
			
			_info = null;
			
			_holder = null;
			
			
			if (_continueBtn)
				_continueBtn.destroy();
			_continueBtn = null;
			
			
			if (_registerBtn)
				_registerBtn.destroy();
			_registerBtn = null;
		}
	}
}
