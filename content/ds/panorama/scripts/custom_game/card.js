var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
};
var CardType;
(function (CardType) {
    CardType[CardType["CARD_TYPE_ATTRIBUTE"] = 0] = "CARD_TYPE_ATTRIBUTE";
    CardType[CardType["CARD_TYPE_SPELL"] = 2] = "CARD_TYPE_SPELL";
    CardType[CardType["CARD_TYPE_MINION"] = 3] = "CARD_TYPE_MINION";
    CardType[CardType["CARD_TYPE_EQUIPMENT"] = 4] = "CARD_TYPE_EQUIPMENT";
})(CardType || (CardType = {}));
// 卡牌基类
var Card = (function () {
    function Card(parent, id, cardType, cardData) {
        // 卡牌的ID
        this.card_id = -1;
        // 是否即将删除
        this.shouldRemove = false;
        // 高亮状态
        this.highLightState = "";
        this.card_id = id;
        this.cardType = cardType;
        this.cardData = cardData;
        this.panel = $.CreatePanel("Panel", parent, "");
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
        this.panel.BLoadLayoutSnippet("Card");
        this.UpdateCardMessage();
    }
    Card.prototype.UpdateCardMessage = function () {
        var str = ('00000' + this.card_id);
        var dig_5_card_id = str.substring(str.length - 5, str.length);
        // 设置卡片图片
        this.panel.FindChildTraverse("CardIllusion").SetImage("file://{resources}/images/custom_game/cards/" + dig_5_card_id + ".png");
        // 设置卡片名称和类别
        this.panel.FindChildTraverse("CardName").text = $.Localize("#CardName_" + dig_5_card_id);
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
        this.panel.FindChildTraverse("CardType").text = "" + prefix_type_str + card_type_str + " ~ " + sub_type_str;
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
        this.panel.FindChildTraverse("CardDescription").text = ability_descriptions + "\n" + card_description;
        var card_lore = $.Localize("#CardLore_" + dig_5_card_id);
        if (card_lore == "" || card_lore == "CardLore_" + dig_5_card_id) {
            $("#CardLore").AddClass("Empty");
        }
        else {
            $("#CardLore").RemoveClass("Empty");
            $("#CardLore").text = card_lore;
        }
        this.panel.FindChildTraverse("CardID").text = $.Localize("#CardID") + ":" + dig_5_card_id;
        this.panel.FindChildTraverse("IllusionArtist").text = $.Localize("#CardArtist") + ":" + (this.cardData.artist || $.Localize("#Unknown"));
    };
    return Card;
}());
// 手牌类
var HandCard = (function (_super) {
    __extends(HandCard, _super);
    function HandCard(parent, id, uniqueId, cardType, cardData) {
        _super.call(this, parent, id, cardType, cardData);
        // 手牌的唯一ID，用以标识这张手牌
        this.uniqueId = "";
        this.uniqueId = uniqueId;
        this.panel.SetPanelEvent("onmouseover", this.ShowHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseout", this.HideHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onactivate", this.OnClickCard.bind(this));
        this.panel.SetHasClass("HandCard", true);
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
}(Card));
