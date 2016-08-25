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
    function HandCard(parent, id, uniqueId, cardType, cardData) {
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
        this.cardType = cardType;
        this.cardData = cardData;
        this.panel = $.CreatePanel("Panel", parent, "");
        this.panel.SetPanelEvent("onmouseover", this.ShowHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseout", this.HideHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onactivate", this.OnClickCard.bind(this));
        this.panel.BLoadLayoutSnippet("HandCard");
        switch (cardType) {
            case CardType.CARD_TYPE_ATTRIBUTE:
                this.panel.AddClass("AttributeCard");
                break;
            case CardType.CARD_TYPE_MINION:
                this.panel.AddClass("MinionCard");
                break;
            case CardType.CARD_TYPE_SPELL:
                this.panel.AddClass("SpellCard");
                break;
            case CardType.CARD_TYPE_EQUIPMENT:
                this.panel.AddClass("EquipmentCard");
                break;
        }
        this.UpdateCardMessage();
        $.Msg("New card instance is created, cardid=" + this.card_id + ", uniqueId = " + this.uniqueId);
    }
    HandCard.prototype.UpdateCardMessage = function () {
        var str = ('00000' + this.card_id);
        var dig_5_card_id = str.substring(str.length - 5, str.length);
        // 设置卡片图片
        $("#CardIllusion").SetImage("file://{resources}/images/custom_game/cards/" + dig_5_card_id + ".png");
        // 设置卡片名称和类别
        $("#CardName").text = $.Localize("#CardName_" + dig_5_card_id);
        var prefix_type_str = "";
        var card_type_str = $.Localize("#CardType_" + this.cardType);
        var sub_type_str = "";
        var pt = this.cardData.prefix_type;
        var st = this.cardData.sub_type;
        for (var id in pt) {
            prefix_type_str += $.Localize("#PrefixType_" + pt[id]);
        }
        for (var id in st) {
            sub_type_str += $.Localize("#SubType_" + st[id]);
        }
        $("#CardType").text = "" + prefix_type_str + card_type_str + " ~ " + sub_type_str;
        // 设置卡片描述
        var abilities = this.cardData.abilities;
        var ability_descriptions = "";
        if (abilities !== undefined) {
            for (var aid in abilities) {
                ability_descriptions += $.Localize("Ability_" + abilities[aid]) + " ";
                ability_descriptions += " ";
            }
        }
        var card_description = $.Localize("#CardDescription_" + dig_5_card_id);
        if (card_description == "CardDescription_" + dig_5_card_id)
            card_description = "";
        $("#CardDescription").text = ability_descriptions + "\n" + card_description;
        var card_lore = $.Localize("#CardLore_" + dig_5_card_id);
        if (card_lore == "" || card_lore == "CardLore_" + dig_5_card_id) {
            $("#CardLore").AddClass("Empty");
        }
        else {
            $("#CardLore").RemoveClass("Empty");
            $("#CardLore").text = card_lore;
        }
        $("#CardID").text = $.Localize("#CardID") + ":" + dig_5_card_id;
        $("#IllusionArtist").text = $.Localize("#CardArtist") + ":" + (this.cardData.artist || $.Localize("#Unknown"));
    };
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
