/// <reference path="hand_card.ts" />
(function () {
    // 手牌列表
    var hand_cards = {};
    var player_tables = GameUI.CustomUIConfig();
    var player_id = Players.GetLocalPlayer();
    // 刷新手牌
    function UpdateHandCards() {
        var handCardContainer = $("#AbilitiesContainer");
        var handCardData = player_tables.GetAllTableValues("hand_cards_" + player_id);
        for (var uniqueId in hand_cards) {
            hand_cards[uniqueId].shouldRemove = true;
        }
        for (var idx in handCardData) {
            var hand_card_data = JSON.parse(handCardData[idx]);
            var unique_id = hand_card_data.unique_id;
            var card_id = hand_card_data.id;
            if (!hand_cards[unique_id]) {
                var new_card = new HandCard(handCardContainer, card_id, unique_id);
                hand_cards[unique_id] = new_card;
            }
            // 如果这个id还存在于服务器的hand中，那么标记为不需要移除
            hand_cards[unique_id].shouldRemove = false;
        }
        for (var uniqueId in hand_cards) {
            // 移除所有需要移除的手牌
            if (hand_cards[uniqueId].shouldRemove) {
                $.Msg("Removing Hand Card " + uniqueId);
                hand_cards[uniqueId].Remove();
                delete hand_cards[uniqueId];
            }
        }
    }
})();
