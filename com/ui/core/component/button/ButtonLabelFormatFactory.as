package com.ui.core.component.button
{
	import com.enum.ui.ButtonEnum;

	import flash.utils.Dictionary;

	public class ButtonLabelFormatFactory
	{
		private static const _lookup:Dictionary = new Dictionary();

		public static function getFormat( type:String ):ButtonLabelFormat
		{
			if (_lookup.hasOwnProperty(type))
				return _lookup[type];

			var format:Object;
			var labelFormat:ButtonLabelFormat;

			switch (type)
			{
				case ButtonEnum.BLUE_A:
					format = {upBold:true, upColor:0xd1e5f7,
							roBold:true, roColor:0xddffff,
							downBold:true, downColor:0x48637a,
							disabledBold:true, disabledColor:0x48637a};
					break;
				case ButtonEnum.GOLD_A:
					format = {upBold:true, upColor:0xffe3b1,
							roBold:true, roColor:0xfff2dd,
							downBold:true, downColor:0x7a6948,
							disabledBold:true, disabledColor:0x7a6948};
					break;
				case ButtonEnum.RED_A:
					format = {upBold:true, upColor:0xffacac,
							roBold:true, roColor:0xffddde,
							downBold:true, downColor:0x7a4948,
							disabledBold:true, disabledColor:0x7a4948};
					break;
				case ButtonEnum.GREEN_A:
					format = {upBold:true, upColor:0xacffb4,
							roBold:true, roColor:0xddffe0,
							downBold:true, downColor:0x487a4f,
							disabledBold:true, disabledColor:0x487a4f};
					break;
				case ButtonEnum.ACCORDIAN_SUBITEM:
					format = {upBold:false, upColor:0x213745,
							roBold:false, roColor:0xd1e5f7,
							downBold:false, downColor:0x213745,
							selectedBold:true, selectedColor:0xd1e5f7};
					break;
				case ButtonEnum.HEADER:
				case ButtonEnum.HEADER_NOTCHED:
					format = {upBold:false, upColor:0x213745,
							roBold:false, roColor:0x213745,
							downBold:false, downColor:0x213745,
							selectedBold:true, selectedColor:0xd1e5f7};
					break;
			}

			if (format)
			{
				labelFormat = new ButtonLabelFormat(format);
				_lookup[type] = labelFormat;
			}

			return labelFormat;
		}

	}
}
