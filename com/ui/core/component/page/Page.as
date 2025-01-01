package com.ui.core.component.page
{
	import flash.display.Sprite;

	import org.shared.ObjectPool;

	public class Page extends Sprite
	{
		private var _icons:Vector.<PageIcon>;
		private var _component:PageComponent;

		public function init( component:PageComponent, IconClass:Class ):void
		{
			if (!IconClass)
				return;

			_icons = new Vector.<PageIcon>;
			_component = component;
			for (var i:int = 0; i < component.iconsPerPage; i++)
			{
				var icon:PageIcon = ObjectPool.get(IconClass);
				icon.init();
				icon.x = ((i % component.iconsPerRow) * component.iconWidth) + ((i % component.iconsPerRow) * component.iconSpacing);
				var row:int       = Math.floor(i / component.iconsPerRow);
				icon.y = (row * component.iconHeight) + (row * component.iconVertSpacing);
				icon.visible = false;
				_icons.push(icon);
				addChild(icon);
			}
		}

		public function update( list:*, pageIndex:int ):void
		{
			var startIndex:int = pageIndex * _component.iconsPerPage;
			var end:int        = startIndex + _component.iconsPerPage;
			if (end > list.length)
				end = list.length - startIndex;
			for (var i:int = 0; i < _component.iconsPerPage; i++)
			{
				if (i + startIndex < list.length)
				{
					_icons[i].update(list[startIndex + i]);
					_icons[i].visible = true;
				} else
					_icons[i].visible = false;
			}
		}

		public function get icons():Vector.<PageIcon>  { return _icons; }

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);

			for (var i:int = 0; i < _icons.length; i++)
				ObjectPool.give(_icons[i]);
			_icons = null;
		}
	}
}
