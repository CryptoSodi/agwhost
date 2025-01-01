package com.ui.modal.mission.captainslog
{
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.mission.MissionInfoVO;
	import com.model.mission.MissionVO;
	import com.ui.UIFactory;
	import com.ui.core.component.bar.VScrollbar;

	import flash.display.Sprite;
	import flash.geom.Rectangle;

	import org.shared.ObjectPool;

	public class MissionOverviewDescription extends Sprite
	{
		private var _bg:Sprite;
		private var _dialogues:Vector.<MissionOverviewDialogue>;
		private var _dragBarRect:Rectangle  = new Rectangle(0, 4, 5, 3);
		private var _holder:Sprite;
		private var _maxHeight:int;
		private var _scrollBar:VScrollbar;
		private var _scrollRect:Rectangle;
		private var _spacing:int            = 134;

		private var _descriptionText:String = 'CodeString.CaptainsLog.Description'; //DESCRIPTION

		public function init():void
		{
			_bg = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED, PanelEnum.HEADER_NOTCHED, 700, 140, 30, 0, 0, _descriptionText, LabelEnum.H2);
			_dialogues = new Vector.<MissionOverviewDialogue>;
			_holder = new Sprite();
			_holder.x = 4;
			_holder.y = 34;

			_scrollRect = new Rectangle(0, 0, 690, 130);

			//scrollbar
			_scrollBar = new VScrollbar();
			_scrollBar.init(7, _scrollRect.height - 15, 681, 32, _dragBarRect, '', 'ScrollBarBMD', '', false, parent, this);
			_scrollBar.onScrollSignal.add(onChangedScroll);
			_scrollBar.updateDisplayedHeight(_scrollRect.height);

			_maxHeight = 0;
			_scrollBar.updateScrollableHeight(_maxHeight);
			_scrollBar.minScroll = _spacing;
			_scrollBar.maxScroll = _spacing;

			addChild(_bg);
			addChild(_holder);
			addChild(_scrollBar);
		}

		public function update( complete:Boolean, greeting:MissionInfoVO, situational:MissionInfoVO, victory:MissionInfoVO, imageLoadCallback:Function ):void
		{
			for (var i:int = 0; i < _dialogues.length; i++)
			{
				_holder.removeChild(_dialogues[i]);
				ObjectPool.give(_dialogues[i]);
			}
			_dialogues.length = 0;
			_maxHeight = 0;

			if (greeting || situational || victory)
			{
				var mod:MissionOverviewDialogue;
				var count:int = 0;

				//add the dialogs
				if (greeting)
				{
					while (greeting.hasDialog)
					{
						mod = ObjectPool.get(MissionOverviewDialogue);
						mod.init(greeting, imageLoadCallback);
						_dialogues.push(mod);
					}
				}

				if (situational)
				{
					while (situational.hasDialog)
					{
						mod = ObjectPool.get(MissionOverviewDialogue);
						mod.init(situational, imageLoadCallback);
						_dialogues.push(mod);
					}
				}

				if (victory && complete)
				{
					while (victory.hasDialog)
					{
						mod = ObjectPool.get(MissionOverviewDialogue);
						mod.init(victory, imageLoadCallback);
						_dialogues.push(mod);
					}
				}

				//position the dialogs in reverse order
				count = -1;
				while (++count < _dialogues.length)
				{
					_dialogues[count].y = _maxHeight;
					_maxHeight += _spacing;
					_holder.addChild(_dialogues[count]);
				}
			}
			if (_maxHeight > 4)
				_maxHeight -= 4;
			_scrollBar.updateScrollableHeight(_maxHeight);
			_scrollBar.updateDisplayedHeight(_scrollRect.height);
			_scrollBar.updateScrollY(0);
			
			_scrollBar.updateScrollY(100);
			//onChangedScroll(100);
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);
			_bg = UIFactory.destroyPanel(_bg);

			for (var i:int = 0; i < _dialogues.length; i++)
			{
				_holder.removeChild(_dialogues[i]);
				ObjectPool.give(_dialogues[i]);
			}
			_dialogues.length = 0;
			_dialogues = null;
			_dragBarRect = null;
			_holder = null;
			_scrollBar = null;
			_scrollRect = null;
		}
	}
}

