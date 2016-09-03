/// <reference path="card.ts" />


function UpdateCardHistory()
{
    let history = CustomNetTables.GetTableValue("card_history", "card_history");
    let column = $("#CardHistoryColumn");
    let localplayer =  Players.GetLocalPlayer()
    column.RemoveAndDeleteChildren();

    for (let index in history){
        let uid = history[index];
        let card_data = CustomNetTables.GetTableValue("card_data", uid);
        let str = ('00000'+card_data.id);
        let dig_5_card_id = str.substring(str.length-5,str.length);
        let image = $.CreatePanel("Image", column, "");
        image.AddClass("HistoryMiniCard");
        image.SetImage(`file://{resources}/images/custom_game/cards/${dig_5_card_id}.png`);

        if(card_data.playerid !== localplayer){
            image.AddClass("EnemyCard");
        }
    }
}

function ShowCardInHistoryPanel(args)
{
    let historypanel = $("#CardShow");
    let uid = args.UniqueID;
    let cardData = CustomNetTables.GetTableValue("card_data", uid);
    let card_type = cardData.card_type;
    let id = cardData.id;
    let playing_card = new Card(historypanel, id, card_type, cardData);
    playing_card.panel.AddClass("ShowedCard");
    playing_card.panel.DeleteAsync(3);
}

(function()
{
    UpdateCardHistory();
    CustomNetTables.SubscribeNetTableListener("card_history", UpdateCardHistory);

    GameEvents.Subscribe("ds_show_card", ShowCardInHistoryPanel);
})();