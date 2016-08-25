/// <reference path="hand_card.ts" />
// 手牌列表
var hand_cards = {};
var player_tables = GameUI.CustomUIConfig().PlayerTables;
var player_id = Players.GetLocalPlayer();
var all_card_data = GameUI.CustomUIConfig().AllCards;
var schedule;
// 刷新手牌
function UpdateHandCards(handCardData) {
    var all_card_data = GameUI.CustomUIConfig().AllCards;
    $.Msg("handCardData");
    $.Msg(handCardData);
    $.Msg('hand card data is changed, refreshing hand card view!');
    var handCardContainer = $("#HandCardContainer");
    $.Msg(handCardData);
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
            var new_card = new HandCard(handCardContainer, card_id, unique_id, card_type);
            hand_cards[unique_id] = new_card;
        }
        // 如果这个id还存在于服务器的hand中，那么标记为不需要移除
        hand_cards[unique_id].shouldRemove = false;
    }
    for (var uniqueId in hand_cards) {
        // 移除所有需要移除的手牌
        if (hand_cards[uniqueId].shouldRemove) {
            hand_cards[uniqueId].Remove();
            delete hand_cards[uniqueId];
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
(function () {
    $.Msg("hand_panel.js is loaded");
    RequestHandCard();
    GameEvents.Subscribe("ds_player_hand_changed", UpdateHandCards);
    GameEvents.Subscribe("ds_highlight_state_changed", UpdateHighLightState);
})();
