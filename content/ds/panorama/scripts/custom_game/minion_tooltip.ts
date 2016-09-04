/// <reference path="card.ts" />
let old_selected_unit: number = -1;

let tooltip_card:TooltipCard;

function UpdateMinionTooltip(){
    let selected_unit = Players.GetLocalPlayerPortraitUnit();
    if (old_selected_unit !== selected_unit && selected_unit !== -1){
        if(!Entities.IsRealHero(selected_unit)){
            let associated_card_id = CustomNetTables.GetTableValue("minion_card_id", selected_unit.toString());
            if (associated_card_id == undefined) return;
            $.GetContextPanel().RemoveClass("Hidden");
            let container = $("#CardHolder");
            let card_data = CustomNetTables.GetTableValue("card_data", associated_card_id.value);
            let id = card_data.id;
            let card_type = card_data.card_type;
            if(tooltip_card !== undefined){
                tooltip_card.panel.DeleteAsync(0);
            }
            tooltip_card = new TooltipCard(container, id, associated_card_id, card_type, card_data, selected_unit);
            tooltip_card.panel.AddClass("TooltipCard");
            tooltip_card.UpdateCardMessage();
            let pos = Entities.GetAbsOrigin(selected_unit);
            let x = Game.WorldToScreenX(pos[0], pos[1], pos[2]);
            let y = Game.WorldToScreenY(pos[0], pos[1], pos[2]);
            tooltip_card.panel.style.position =x + "px " + y + "px 0px;";

        }else{
            $.GetContextPanel().AddClass("Hidden");
        }
    }
    old_selected_unit = selected_unit;
    $.Schedule(1/30, UpdateMinionTooltip);
}
(function(){
    UpdateMinionTooltip();
})();