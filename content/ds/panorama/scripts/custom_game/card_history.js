/// <reference path="card.ts" />
function UpdateCardHistory() {
    var history = CustomNetTables.GetTableValue("card_history", "card_history");
    var column = $("#CardHistoryColumn");
    var localplayer = Players.GetLocalPlayer();
    column.RemoveAndDeleteChildren();
    for (var index in history) {
        var uid = history[index];
        var card_data = CustomNetTables.GetTableValue("card_data", uid);
        var str = ('00000' + card_data.id);
        var dig_5_card_id = str.substring(str.length - 5, str.length);
        var image = $.CreatePanel("Image", column, "");
        image.AddClass("HistoryMiniCard");
        image.SetImage("file://{resources}/images/custom_game/cards/" + dig_5_card_id + ".png");
        if (card_data.playerid !== localplayer) {
            image.AddClass("EnemyCard");
        }
    }
}
function ShowCardInHistoryPanel(args) {
    var historypanel = $("#CardShow");
    var uid = args.UniqueID;
    var cardData = CustomNetTables.GetTableValue("card_data", uid);
    var card_type = cardData.card_type;
    var id = cardData.id;
    var playing_card = new Card(historypanel, id, card_type, cardData);
    playing_card.panel.AddClass("ShowedCard");
    playing_card.panel.DeleteAsync(3);
}
(function () {
    UpdateCardHistory();
    CustomNetTables.SubscribeNetTableListener("card_history", UpdateCardHistory);
    GameEvents.Subscribe("ds_show_card", ShowCardInHistoryPanel);
})();
