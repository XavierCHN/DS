var handCards = []

function PrefixInteger(num, length) {
	return (Array(length).join('0') + num).slice(-length);
}

function ShowHandCards()
{
	// TODO 抄一个技能的实现方式！
	var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
	var playerID = Players.GetLocalPlayer()
	var hand = PlayerTables.GetAllTableValues("hand_cards_" + playerID)
	var parent = $.GetContextPanel()
	var idx = parent.GetChildCount()
	for (var i = 0; i < idx -1; i++)
	{

	}
	for(var i in hand){
		var id = PrefixInteger(hand[i], 5)
		$.Msg(id);
	}
	$.Schedule(0.5,ShowHandCards)
}

(function()
{
	ShowHandCards()
})();
