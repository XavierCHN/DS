/// <reference path="card.ts" />
var old_selected_unit = -1;
var tooltip_card;
function UpdateMinionTooltip() {
    var selected_unit = Players.GetLocalPlayerPortraitUnit();
    if (old_selected_unit !== selected_unit && selected_unit !== -1) {
        if (!Entities.IsRealHero(selected_unit)) {
            var associated_card_id = CustomNetTables.GetTableValue("minion_card_id", selected_unit.toString());
            if (associated_card_id == undefined)
                return;
            $.GetContextPanel().RemoveClass("Hidden");
            var container = $("#CardHolder");
            var card_data = CustomNetTables.GetTableValue("card_data", associated_card_id.value);
            var id = card_data.id;
            var card_type = card_data.card_type;
            if (tooltip_card !== undefined) {
                tooltip_card.panel.DeleteAsync(0);
            }
            tooltip_card = new TooltipCard(container, id, associated_card_id, card_type, card_data, selected_unit);
            tooltip_card.panel.AddClass("TooltipCard");
            tooltip_card.UpdateCardMessage();
            var pos = Entities.GetAbsOrigin(selected_unit);
            var x = Game.WorldToScreenX(pos[0], pos[1], pos[2]);
            var y = Game.WorldToScreenY(pos[0], pos[1], pos[2]);
            tooltip_card.panel.style.position = x + "px " + y + "px 0px;";
        }
        else {
            $.GetContextPanel().AddClass("Hidden");
        }
    }
    old_selected_unit = selected_unit;
    $.Schedule(1 / 30, UpdateMinionTooltip);
}
(function () {
    UpdateMinionTooltip();
})();
