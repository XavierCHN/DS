// // 属性卡
// class AttributeCard extends HandCard{
//     constructor(parent: Panel, id:number, uniqueId: string){
//         super(parent, id, uniqueId);
//         this.panel.BLoadLayoutSnippet("AttributeCard");
//     }
// }
// // 生物卡
// class MinionCard extends HandCard{
//     constructor(parent: Panel, id:number, uniqueId: string){
//         super(parent, id, uniqueId);
//         this.panel.BLoadLayoutSnippet("MinionCard");
//     }
// }
// // 法术卡
// class SpellCard extends HandCard{
//     constructor(parent: Panel, id:number, uniqueId: string){
//         super(parent, id, uniqueId);
//         this.panel.BLoadLayoutSnippet("SpellCard");
//     }
// }
// // 装备卡
// class EquipmentCard extends HandCard{
//     constructor(parent:Panel, id:number, uniqueId: string){
//         super(parent, id, uniqueId);
//         this.panel.BLoadLayoutSnippet("EquipmentCard");
//     }
// }
var CardType;
(function (CardType) {
    CardType[CardType["CARD_TYPE_ATTRIBUTE"] = 0] = "CARD_TYPE_ATTRIBUTE";
    CardType[CardType["CARD_TYPE_SPELL"] = 2] = "CARD_TYPE_SPELL";
    CardType[CardType["CARD_TYPE_MINION"] = 3] = "CARD_TYPE_MINION";
    CardType[CardType["CARD_TYPE_EQUIPMENT"] = 4] = "CARD_TYPE_EQUIPMENT";
})(CardType || (CardType = {}));
// 卡牌基类
var HandCard = (function () {
    function HandCard(parent, id, uniqueId, cardType) {
        // 所显示的卡牌的ID
        this.card_id = -1;
        // 卡牌的唯一ID，在卡牌实例化的时候生成
        this.uniqueId = "";
        // 是否即将删除
        this.shouldRemove = false;
        // 高亮状态
        this.highLightState = "";
        this.card_id = id;
        this.uniqueId = uniqueId;
        this.panel = $.CreatePanel("Panel", parent, "");
        this.panel.SetPanelEvent("onmouseover", this.ShowHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseout", this.HideHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onactivate", this.OnClickCard.bind(this));
        switch (cardType) {
            case CardType.CARD_TYPE_ATTRIBUTE:
                this.panel.BLoadLayoutSnippet("AttributeCard");
                break;
            case CardType.CARD_TYPE_MINION:
                this.panel.BLoadLayoutSnippet("MinionCard");
                break;
            case CardType.CARD_TYPE_SPELL:
                this.panel.BLoadLayoutSnippet("SpellCard");
                break;
            case CardType.CARD_TYPE_EQUIPMENT:
                this.panel.BLoadLayoutSnippet("EquipmentCard");
                break;
            default:
                this.panel.BLoadLayoutSnippet("HandCard");
        }
        $.Msg("New card instance is created, cardid=" + this.card_id + ", uniqueId = " + this.uniqueId);
    }
    HandCard.prototype.ShowHandCardTooltip = function () {
    };
    HandCard.prototype.HideHandCardTooltip = function () {
    };
    HandCard.prototype.OnClickCard = function () {
    };
    HandCard.prototype.Remove = function () {
        this.panel.DeleteAsync(0);
    };
    HandCard.prototype.UpdateHighlightState = function (newState) {
        if (newState !== "") {
            this.panel.SetHasClass(newState, true);
        }
        else {
            this.panel.SetHasClass(this.highLightState, false);
        }
        this.highLightState = newState;
    };
    return HandCard;
}());
