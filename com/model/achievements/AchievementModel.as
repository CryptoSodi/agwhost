package com.model.achievements
{
	import com.enum.ToastEnum;
	import com.event.ToastEvent;
	import com.model.Model;
	import com.model.prototype.PrototypeModel;
	import com.service.server.incoming.data.AchievementData;
	import com.service.server.incoming.data.ScoreData;
	import com.service.server.incoming.data.MissionScoreData;
	import com.service.server.incoming.starbase.StarbaseAchievementsResponse;
	import com.service.server.incoming.starbase.StarbaseAllScoresResponse;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	public class AchievementModel extends Model
	{
		public var onAchievementsUpdated:Signal;
		public var onAllScoresUpdated:Signal;

		private var _achievements:Dictionary;
		private var _scores:Dictionary;
		private var _missionScores:Dictionary;


		public function AchievementModel()
		{
			super();

			_achievements = new Dictionary();
			_scores = new Dictionary();
			_missionScores = new Dictionary();
			onAchievementsUpdated = new Signal(Dictionary);
			onAllScoresUpdated = new Signal(Dictionary);
		}

		public function addData( achievementResponse:StarbaseAchievementsResponse ):void
		{
			var i:uint;
			var currentAchievementData:AchievementData;
			var currentScoreData:ScoreData;
			var currentAchievement:AchievementVO;
			var currentScore:ScoreVO;
			var achievements:Vector.<AchievementData> = achievementResponse.achievements;
			var scores:Vector.<ScoreData>             = achievementResponse.scores;
			var len:uint                              = scores.length;

			for (; i < len; ++i)
			{
				currentScoreData = scores[i];
				currentScore = new ScoreVO(currentScoreData.key, currentScoreData.scoreKey, currentScoreData.value);
				_scores[currentScoreData.scoreKey] = currentScore;
			}

			len = achievements.length;
			for (i = 0; i < len; ++i)
			{
				currentAchievementData = achievements[i];
				currentAchievement = new AchievementVO(currentAchievementData.key, currentAchievementData.achievementPrototype, currentAchievementData.claimedFlag);
				_achievements[currentAchievementData.key] = currentAchievement;

				if (achievementResponse.unlockToast)
					popToast(currentAchievement);
			}


			onAchievementsUpdated.dispatch(_achievements, _scores);
		}
		
		public function addAllScoreData( allScoresResponse:StarbaseAllScoresResponse ):void
		{
			var i:uint;
			var currentScoreData:ScoreData;
			var currentMissionScoreData:MissionScoreData;
			var currentScore:ScoreVO;
			var currentMissionScore:MissionScoreVO;
			var scores:Vector.<ScoreData>             = allScoresResponse.scores;
			var missionScores:Vector.<MissionScoreData>      = allScoresResponse.missionScores;
			
			var len:uint = scores.length;
			for (; i < len; ++i)
			{
				currentScoreData = scores[i];
				currentScore = new ScoreVO(currentScoreData.key, currentScoreData.scoreKey, currentScoreData.value);
				_scores[currentScoreData.scoreKey] = currentScore;
			}
			
			len = missionScores.length;
			for (; i < len; ++i)
			{
				currentMissionScoreData = missionScores[i];
				currentMissionScore = new MissionScoreVO(currentMissionScoreData.key, currentMissionScoreData.instancedMissionID, currentMissionScoreData.bestTime);
				_missionScores[currentMissionScoreData.instancedMissionID] = currentMissionScore;
			}
			
			onAllScoresUpdated.dispatch(_scores, _missionScores);
		}

		public function getScoreValueByName( v:String ):uint
		{
			if (v in _scores)
				return _scores[v].value;

			return 0;
		}

		private function popToast( achievement:AchievementVO ):void
		{
			var toastEvent:ToastEvent = new ToastEvent();
			toastEvent.toastType = ToastEnum.ACHIEVEMENT;
			toastEvent.prototype = PrototypeModel.instance.getAchievementPrototypeByName(achievement.achievementPrototype);
			dispatch(toastEvent);
		}

	}
}
