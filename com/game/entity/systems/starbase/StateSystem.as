package com.game.entity.systems.starbase
{
	import com.Application;
	import com.controller.transaction.TransactionController;
	import com.enum.TypeEnum;
	import com.event.TransactionEvent;
	import com.event.signal.TransactionSignal;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.VCList;
	import com.game.entity.components.shared.fsm.FSM;
	import com.game.entity.components.starbase.Construction;
	import com.game.entity.components.starbase.State;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.nodes.starbase.StateNode;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.ResearchVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;

	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	import org.adobe.utils.StringUtil;
	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;
	import org.shared.ObjectPool;

	/**
	 * Shows progress bars over buildings and handles the animation sequence
	 * for building construction and repair
	 */
	public class StateSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.starbase.StateNode")]
		public var nodes:NodeList;

		private var _eventDispatcher:IEventDispatcher;
		private var _game:Game;
		private var _starbaseFactory:IStarbaseFactory;
		private var _starbaseModel:StarbaseModel;
		private var _time:Number;
		private var _transactionController:TransactionController;
		private var _transactionModel:TransactionModel;

		override public function addToGame( game:Game ):void
		{
			_game = game;
			_time = 0;

			//add the transaction listeners
			_transactionModel.addListener(TransactionSignal.TRANSACTION_REMOVED, onTransactionRemoved);
			_transactionModel.addListener(TransactionSignal.TRANSACTION_UPDATED, onTransactionUpdated);

			//go through the current transactions and set states
			var transactions:Dictionary = _transactionModel.transactions;
			for each (var transaction:TransactionVO in transactions)
			{
				onTransactionUpdated(transaction);
			}
		}

		/**
		 * Acts as a state machine for building construction animation
		 * and also updates the progress bars of transactions
		 */
		override public function update( time:Number ):void
		{
			_time += time;
			//update the progress bars if there are any
			if (nodes.head && _time >= 1)
			{
				var animation:Animation;
				var state:State;
				for (var node:StateNode = nodes.head; node; node = node.next)
				{
					state = node.state;
					state.text = StringUtil.getBuildTime(state.remainingTime * .001, (Application.LANGUAGE == 'en') ? 2 : 1);
					if (state.component)
					{
						animation = state.component.get(Animation);
						animation.scaleX = state.percentageDone;
						animation.text = state.text;
						if (animation.render)
							animation.render.scaleX = state.percentageDone;
					}
				}
				_time -= 1;
			}
		}

		private function onTransactionUpdated( transaction:TransactionVO ):void
		{
			//ignore transactions that were instantly built
			if (transaction.timeMS <= 0)
				return;
			var animation:Animation;
			var entity:Entity = getEntity(transaction);
			if (entity)
			{
				var vcList:VCList = entity.get(VCList);
				var state:State   = entity.get(State);
				if (state == null)
				{
					state = ObjectPool.get(State);
					entity.add(state, State);
				}

				state.addTransaction(transaction);
				updateState(entity);
			}
		}

		private function onTransactionRemoved( transaction:TransactionVO ):void
		{
			//ignore transactions that were instantly built
			if (transaction.timeMS == 0)
				return;
			var entity:Entity = getEntity(transaction);
			if (entity && entity.has(State))
			{
				var state:State = entity.get(State);
				state.removeTransaction(transaction.id);
				updateState(entity);
			}
		}

		private function updateState( entity:Entity ):void
		{
			var animation:Animation;
			var state:State   = entity.get(State);
			var vcList:VCList = entity.get(VCList);

			if (!state.showConstruction)
			{
				var construction:Entity = vcList.getComponent(TypeEnum.BUILDING_CONSTRUCTION);
				//set the state of the building construction if it has one
				if (construction)
					FSM(construction.get(FSM)).state = Construction.BEAM_ASCEND;
				else //call the remove, just in case the transaction finished before we had time to create the construction animation
					vcList.removeComponentType(TypeEnum.BUILDING_CONSTRUCTION);
			} else if (state.showConstruction)
				vcList.addComponentType(TypeEnum.BUILDING_CONSTRUCTION);

			if (state.transactionCount <= 0)
			{
				vcList.removeComponentType(TypeEnum.STATE_BAR);
				ObjectPool.give(entity.remove(State));
				_starbaseFactory.updateStarbaseBuilding(entity);
			} else
			{
				vcList.addComponentType(TypeEnum.STATE_BAR);
				state.text = StringUtil.getBuildTime(state.remainingTime * .001, (Application.LANGUAGE == 'en') ? 2 : 1);
				if (state.component)
				{
					animation = state.component.get(Animation);
					animation.scaleX = state.percentageDone;
					animation.text = state.text;
					if (animation.render)
						animation.render.scaleX = state.percentageDone;
				}
			}
		}

		private function getEntity( transaction:TransactionVO ):Entity
		{
			var buildingVO:BuildingVO;
			var entity:Entity = _game.getEntity(transaction.id);
			if (!entity)
			{
				//if we haven't found an entity this may be a research or something related to a ship or fleet. 
				//find the associated building.
				if (transaction.baseID == _starbaseModel.currentBase.id)
				{
					switch (transaction.type)
					{
						case TransactionEvent.STARBASE_RESEARCH:
							var researchVO:ResearchVO = _starbaseModel.getResearchByID(transaction.id);
							if (researchVO)
							{
								entity = _game.getEntity(_starbaseModel.getBuildingByClass(researchVO.requiredBuildingClass).id);
							}
							break;
						case TransactionEvent.STARBASE_REFIT_SHIP:
						case TransactionEvent.STARBASE_RECYCLE_SHIP:
						case TransactionEvent.STARBASE_BUILD_SHIP:
							buildingVO = _starbaseModel.getBuildingByClass(TypeEnum.CONSTRUCTION_BAY);
							if (buildingVO)
								entity = _game.getEntity(buildingVO.id);
							break;
						case TransactionEvent.STARBASE_REPAIR_FLEET:
							buildingVO = _starbaseModel.getBuildingByClass(TypeEnum.DOCK);
							if (buildingVO)
								entity = _game.getEntity(buildingVO.id);
							break;
					}

				}
			}
			if (entity && entity.has(VCList))
				return entity;
			return null;
		}

		[Inject]
		public function set eventDispatcher( v:IEventDispatcher ):void  { _eventDispatcher = v; }
		[Inject]
		public function set starbaseFactory( v:IStarbaseFactory ):void  { _starbaseFactory = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
		[Inject]
		public function set transactionModel( v:TransactionModel ):void  { _transactionModel = v; }

		override public function removeFromGame( game:Game ):void
		{
			nodes = null;
			_eventDispatcher = null;

			//remove the transaction listeners
			_transactionModel.removeListener(onTransactionRemoved);
			_transactionModel.removeListener(onTransactionUpdated);

			_game = null;
			_starbaseModel = null;
			_transactionController = null;
			_transactionModel = null;
		}
	}
}


