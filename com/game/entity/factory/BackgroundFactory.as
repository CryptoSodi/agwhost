package com.game.entity.factory
{
	import com.enum.CategoryEnum;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.game.entity.systems.shared.background.BackgroundItem;
	import com.model.asset.AssetVO;

	import org.ash.core.Entity;
	import org.shared.ObjectPool;

	public class BackgroundFactory extends BaseFactory implements IBackgroundFactory
	{
		public function createBackground( item:BackgroundItem ):Entity
		{
			var assetVO:AssetVO       = _assetModel.getEntityData(item.type);
			var backgroundItem:Entity = createEntity();
			//detail component
			var detail:Detail         = ObjectPool.get(Detail);
			detail.init(CategoryEnum.BACKGROUND, assetVO);
			backgroundItem.add(detail);
			//position component
			var pos:Position          = ObjectPool.get(Position);
			pos.init(item.x, item.y, 0, item.layer, item.parallaxSpeed);
			backgroundItem.add(pos);
			//animation component
			var anim:Animation        = ObjectPool.get(Animation);
			anim.init(item.type, item.label, false, 0, 30, true);
			anim.scaleX = anim.scaleY = item.scale;
			anim.allowTransform = true;
			backgroundItem.add(anim);
			//assign the name
			backgroundItem.id = item.id;
			//add to the game
			addEntity(backgroundItem);
			return backgroundItem;
		}

		public function destroyBackground( backgroundItem:Entity ):void
		{
			if (backgroundItem == null)
				return;
			destroyEntity(backgroundItem);
			ObjectPool.give(backgroundItem.remove(Detail));
			ObjectPool.give(backgroundItem.remove(Position));
			ObjectPool.give(backgroundItem.remove(Animation));
		}
	}
}
