/// <reference path="card.ts" />

enum CardBehavior{
    CARD_BEHAVIOR_NO_TARGET = 0,
    CARD_BEHAVIOR_SINGLE_TARGET = 1,
    CARD_BEHAVIOR_POINT = 2,
}

// 手牌列表
let hand_cards = <{[uniqueId: string ]: HandCard}>{};
let player_tables = GameUI.CustomUIConfig().PlayerTables;
let player_id :number = Players.GetLocalPlayer();
let all_card_data = GameUI.CustomUIConfig().AllCards;
var schedule;
// 刷新手牌
function UpdateHandCards(handCardData){
    let all_card_data = GameUI.CustomUIConfig().AllCards;
    let handCardContainer = $("#HandCardContainer");

    for( let uniqueId in hand_cards){
        hand_cards[uniqueId].shouldRemove = true;
    }
    let _cc:number = 0;
    for (let __x in handCardData)
        _cc++;

    for(let idx in handCardData){
        let hand_card_data = JSON.parse(handCardData[idx]);
        let unique_id = hand_card_data.unique_id;
        let card_id = hand_card_data.id;

        // 如果不存在这个ID的卡牌，则创建新的卡牌
        if(!hand_cards[unique_id]){
            let card_data = all_card_data[card_id];
            let card_type = card_data["card_type"];
            let new_card = new HandCard(handCardContainer, card_id, unique_id, card_type, card_data);
            hand_cards[unique_id] = new_card;
        }
        // 如果这个id还存在于服务器的hand中，那么标记为不需要移除
        hand_cards[unique_id].shouldRemove = false;
        hand_cards[unique_id].SetHandCount(_cc);
    }

    for( let uniqueId in hand_cards){
        if(hand_cards[uniqueId].shouldRemove){
            // 移除所有需要移除的手牌
            hand_cards[uniqueId].Remove();
            delete hand_cards[uniqueId];
        }else{
            // 刷新不需要移除的手牌
            hand_cards[uniqueId].UpdateCardMessage();
        }
    }
}

// 高亮手牌
function UpdateHighLightState(args){
    let uniqueId = args.CardID;
    let newState = args.NewState;

    for (let uid in hand_cards){
        if(uid == uniqueId){
            hand_cards[uid].UpdateHighlightState(newState)
        }
    }
}

function RequestHandCard(){
    $.Msg("requesting card data at server l")
    GameEvents.SendCustomGameEventToServer("ds_request_hand",{})
}

function ExecuteCardProxy(args){
    let cardBehavior = args.behavior;
    let ability_name = "";
    let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());

    switch(cardBehavior){
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

    let ability = Entities.GetAbilityByName(hero, ability_name);
    if(ability_name == "" || ability == -1) {
        $.Msg(`unable to find valid ability to execute for behavior${cardBehavior}, ability_name=${ability_name}`);
        return;
    }
    $.Msg(`begin to execute abilty ${ability_name}, abilityIndex = ${ability}`)
    Abilities.ExecuteAbility(ability, hero, false);
}

function UpdateHandCardCount(args){

}

(function(){
    $.Msg(`hand_panel.js is loaded`);
    RequestHandCard();
    GameEvents.Subscribe("ds_player_hand_changed", UpdateHandCards);
    GameEvents.Subscribe("ds_highlight_state_changed", UpdateHighLightState);
    GameEvents.Subscribe("ds_execute_card_proxy", ExecuteCardProxy);
    GameEvents.Subscribe("ds_player_hand_count_changed", UpdateHandCardCount)
})();