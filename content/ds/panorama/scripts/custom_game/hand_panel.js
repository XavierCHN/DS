/// <reference path="card.ts" />
var CardBehavior;
(function (CardBehavior) {
    CardBehavior[CardBehavior["CARD_BEHAVIOR_NO_TARGET"] = 0] = "CARD_BEHAVIOR_NO_TARGET";
    CardBehavior[CardBehavior["CARD_BEHAVIOR_SINGLE_TARGET"] = 1] = "CARD_BEHAVIOR_SINGLE_TARGET";
    CardBehavior[CardBehavior["CARD_BEHAVIOR_POINT"] = 2] = "CARD_BEHAVIOR_POINT";
})(CardBehavior || (CardBehavior = {}));
// 手牌列表
var hand_cards = {};
var player_tables = GameUI.CustomUIConfig().PlayerTables;
var player_id = Players.GetLocalPlayer();
var all_card_data = GameUI.CustomUIConfig().AllCards;
var schedule;
// 刷新手牌
function UpdateHandCards(handCardData) {
    var all_card_data = GameUI.CustomUIConfig().AllCards;
    var handCardContainer = $("#HandCardContainer");
    for (var uniqueId in hand_cards) {
        hand_cards[uniqueId].shouldRemove = true;
    }
    for (var idx in handCardData) {
        var hand_card_data = JSON.parse(handCardData[idx]);
        var unique_id = hand_card_data.unique_id;
        var card_id = hand_card_data.id;
        // 如果不存在这个ID的卡牌，则创建新的卡牌
        if (!hand_cards[unique_id]) {
            var card_data = all_card_data[card_id];
            var card_type = card_data["card_type"];
            var new_card = new HandCard(handCardContainer, card_id, unique_id, card_type, card_data);
            hand_cards[unique_id] = new_card;
        }
        // 如果这个id还存在于服务器的hand中，那么标记为不需要移除
        hand_cards[unique_id].shouldRemove = false;
    }
    for (var uniqueId in hand_cards) {
        if (hand_cards[uniqueId].shouldRemove) {
            // 移除所有需要移除的手牌
            hand_cards[uniqueId].Remove();
            delete hand_cards[uniqueId];
        }
        else {
            // 刷新不需要移除的手牌
            hand_cards[uniqueId].UpdateCardMessage();
        }
    }
}
// 高亮手牌
function UpdateHighLightState(args) {
    var uniqueId = args.CardID;
    var newState = args.NewState;
    for (var uid in hand_cards) {
        if (uid == uniqueId) {
            hand_cards[uid].UpdateHighlightState(newState);
        }
    }
}
function RequestHandCard() {
    $.Msg("requesting card data at server l");
    GameEvents.SendCustomGameEventToServer("ds_request_hand", {});
}
function ExecuteCardProxy(args) {
    var cardBehavior = args.behavior;
    var ability_name = "";
    var hero = Players.GetPlayerSelectedHero(Players.GetLocalPlayer());
    switch (cardBehavior) {
        case CardBehavior.CARD_BEHAVIOR_POINT:
            ability_name = "ds_point";
            break;
        case CardBehavior.CARD_BEHAVIOR_NO_TARGET:
            ability_name = "ds_no_target";
            break;
        case CardBehavior.CARD_BEHAVIOR_SINGLE_TARGET:
            ability_name = "ds_single_target";
            break;
    }
    var ability = Entities.GetAbilityByName(hero, ability_name);
    if (ability_name == "" || ability == -1) {
        $.Msg("unable to find valid ability to execute for card behavior" + cardBehavior + ", ability_name=" + ability_name);
        return;
    }
    $.Msg("begin to execute abilty");
    Abilities.ExecuteAbility(ability, hero, false);
}
(function () {
    $.Msg("hand_panel.js is loaded");
    RequestHandCard();
    GameEvents.Subscribe("ds_player_hand_changed", UpdateHandCards);
    GameEvents.Subscribe("ds_highlight_state_changed", UpdateHighLightState);
    GameEvents.Subscribe("ds_execute_card_proxy", ExecuteCardProxy);
})();
