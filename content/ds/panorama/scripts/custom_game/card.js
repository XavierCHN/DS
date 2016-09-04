var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
};
var CardType;
(function (CardType) {
    CardType[CardType["CARD_TYPE_ATTRIBUTE"] = 0] = "CARD_TYPE_ATTRIBUTE";
    CardType[CardType["CARD_TYPE_SPELL"] = 1] = "CARD_TYPE_SPELL";
    CardType[CardType["CARD_TYPE_MINION"] = 2] = "CARD_TYPE_MINION";
    CardType[CardType["CARD_TYPE_EQUIPMENT"] = 3] = "CARD_TYPE_EQUIPMENT";
})(CardType || (CardType = {}));
var CardAttribute;
(function (CardAttribute) {
    CardAttribute[CardAttribute["ATTRIBUTE_NONE"] = 0] = "ATTRIBUTE_NONE";
    CardAttribute[CardAttribute["ATTRIBUTE_STRENGTH"] = 1] = "ATTRIBUTE_STRENGTH";
    CardAttribute[CardAttribute["ATTRIBUTE_AGILITY"] = 2] = "ATTRIBUTE_AGILITY";
    CardAttribute[CardAttribute["ATTRIBUTE_INTELLECT"] = 3] = "ATTRIBUTE_INTELLECT";
})(CardAttribute || (CardAttribute = {}));
var CardTiming;
(function (CardTiming) {
    CardTiming[CardTiming["TIMING_NORMAL"] = 0] = "TIMING_NORMAL";
    CardTiming[CardTiming["TIMING_INSTANT"] = 1] = "TIMING_INSTANT";
})(CardTiming || (CardTiming = {}));
// 卡牌基类
var Card = (function () {
    function Card(parent, id, cardType, cardData) {
        // 卡牌的ID
        this.card_id = -1;
        // 是否即将删除
        this.shouldRemove = false;
        this.card_id = id;
        this.cardType = cardType;
        this.cardData = cardData;
        this.panel = $.CreatePanel("Panel", parent, "");
        switch (this.cardData.main_attr) {
            case CardAttribute.ATTRIBUTE_STRENGTH:
                this.panel.AddClass("MainAttributeStrength");
                break;
            case CardAttribute.ATTRIBUTE_AGILITY:
                this.panel.AddClass("MainAttributeAgility");
                break;
            case CardAttribute.ATTRIBUTE_INTELLECT:
                this.panel.AddClass("MainAttributeIntellect");
                break;
            case CardAttribute.ATTRIBUTE_NONE:
                this.panel.AddClass("MainAttributeNone");
                break;
        }
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
        this.panel.BLoadLayout("file://{resources}/layout/custom_game/card.xml", false, false);
        this.UpdateCardMessage();
    }
    Card.prototype.UpdateCardMessage = function () {
        var str = ('00000' + this.card_id);
        var dig_5_card_id = str.substring(str.length - 5, str.length);
        // 设置卡片图片
        this.panel.FindChildTraverse("CardIllusion").SetImage("file://{resources}/images/custom_game/cards/" + dig_5_card_id + ".png");
        // 设置费用
        var cost_panel = this.panel.FindChildTraverse("CardCost");
        var mana_label = this.panel.FindChildTraverse("CardCost_Mana");
        var attr_panel = this.panel.FindChildTraverse("CardCost_Attributes");
        var str_cost = this.cardData.cost.str;
        var agi_cost = this.cardData.cost.agi;
        var int_cost = this.cardData.cost.int;
        var mana_cost = this.cardData.cost.mana;
        if ((str_cost == undefined || str_cost <= 0) &&
            (agi_cost == undefined || agi_cost <= 0) &&
            (int_cost == undefined || int_cost <= 0) &&
            (mana_cost == undefined || mana_cost <= 0)) {
            cost_panel.AddClass("NoCost");
        }
        else {
            cost_panel.RemoveClass("NoCost");
            attr_panel.RemoveAndDeleteChildren();
            if (str_cost !== undefined && str_cost > 0) {
                for (var i = 0; i < str_cost; i++) {
                    var s = $.CreatePanel("Image", attr_panel, "");
                    s.SetImage("file://{resources}/images/custom_game/card/card_cost_str.png");
                }
            }
            if (agi_cost !== undefined && agi_cost > 0) {
                for (var i = 0; i < agi_cost; i++) {
                    var s = $.CreatePanel("Image", attr_panel, "");
                    s.SetImage("file://{resources}/images/custom_game/card/card_cost_agi.png");
                }
            }
            if (int_cost !== undefined && int_cost > 0) {
                for (var i = 0; i < int_cost; i++) {
                    var s = $.CreatePanel("Image", attr_panel, "");
                    s.SetImage("file://{resources}/images/custom_game/card/card_cost_int.png");
                }
            }
            mana_cost = mana_cost || 0;
            mana_label.text = mana_cost;
        }
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
        this.panel.FindChildTraverse("CardType").text = "" + prefix_type_str + card_type_str + " " + (sub_type_str == "" ? "" : "~") + " " + sub_type_str;
        // 设置使用时机标志
        if (this.cardData.timing == CardTiming.TIMING_INSTANT)
            this.panel.FindChildTraverse("TimingImage").SetImage("file://{resources}/images/custom_game/card/timing_instant.png");
        // 设置卡片描述
        // 技能部分使用互相独立的panel来制作 
        var ability_container = this.panel.FindChildTraverse("CardAbilities");
        var abilities = this.cardData.abilities;
        ability_container.RemoveAndDeleteChildren();
        if (abilities !== undefined) {
            for (var aid in abilities) {
                var ability_data = JSON.parse(abilities[aid]);
                if (ability_data == null)
                    continue;
                var ability_label = $.CreatePanel("Label", ability_container, "");
                ability_label.text = $.Localize("Ability_" + ability_data["name"]);
                ability_label.AddClass("text-h3");
            }
        }
        var card_description = $.Localize("#CardDescription_" + dig_5_card_id);
        if (card_description == "CardDescription_" + dig_5_card_id)
            card_description = "";
        this.panel.FindChildTraverse("CardDescription").text = "" + card_description;
        var card_lore = $.Localize("#CardLore_" + dig_5_card_id);
        if (card_lore == "" || card_lore == "CardLore_" + dig_5_card_id) {
            this.panel.FindChildTraverse("CardLore").AddClass("Empty");
            this.panel.FindChildTraverse("CardLore").text = card_lore;
        }
        else {
            this.panel.FindChildTraverse("CardLore").RemoveClass("Empty");
            this.panel.FindChildTraverse("CardLore").text = card_lore;
        }
        this.panel.FindChildTraverse("CardID").text = $.Localize("#CardID") + ":" + dig_5_card_id;
        this.panel.FindChildTraverse("IllusionArtist").text = $.Localize("#CardArtist") + ":" + (this.cardData.artist || $.Localize("#Unknown"));
        // 设置生物的攻击力和防御力
        if (this.cardType == CardType.CARD_TYPE_MINION) {
            var ad_panel = this.panel.FindChildTraverse("AttackDefLabel");
            ad_panel.text = this.cardData.atk + "/" + this.cardData.hp;
        }
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
        // 用以记录当前手牌数量
        this.handCount = 1;
        // 高亮状态
        this.highLightState = "";
        this.uniqueId = uniqueId;
        this.panel.SetPanelEvent("onmouseover", this.ShowHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseout", this.HideHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onactivate", this.OnClickCard.bind(this));
        this.panel.SetHasClass("HandCard", true);
    }
    HandCard.prototype.ShowHandCardTooltip = function () {
    };
    HandCard.prototype.HideHandCardTooltip = function () {
    };
    HandCard.prototype.OnClickCard = function () {
        GameEvents.SendCustomGameEventToServer("ds_player_click_card", {
            PlayerID: Players.GetLocalPlayer(),
            UniqueId: this.uniqueId,
        });
    };
    HandCard.prototype.Remove = function () {
        this.panel.DeleteAsync(0);
    };
    HandCard.prototype.UpdateHighlightState = function (newState) {
        this.panel.SetHasClass(this.highLightState, false);
        this.panel.SetHasClass(newState, true);
        this.highLightState = newState;
    };
    HandCard.prototype.SetHandCount = function (count) {
        this.panel.SetHasClass("CardCount_" + this.handCount, false);
        this.handCount = count;
        this.panel.SetHasClass("CardCount_" + this.handCount, true);
    };
    return HandCard;
}(Card));
// 卡牌收藏中的牌
var CollectionCard = (function (_super) {
    __extends(CollectionCard, _super);
    function CollectionCard(parent, id, cardType, cardData) {
        _super.call(this, parent, id, cardType, cardData);
    }
    return CollectionCard;
}(Card));
// 套牌中的牌（小牌）
var SmallDeckCard = (function () {
    function SmallDeckCard(cardId, count) {
        this.cardId = cardId;
        this.cardCount = count;
    }
    return SmallDeckCard;
}());
var ActiveAbilityLabel = (function () {
    function ActiveAbilityLabel(name, container, owner) {
        this.name = name;
        this.owner = owner;
        this.label = $.CreatePanel("Label", container, "");
        this.label.AddClass("ActiveAbilityLabel");
        this.label.AddClass("text-h2");
        this.label.text = $.Localize("Ability_" + this.name);
        this.label.SetPanelEvent("onactivate", this.OnClickActiveAbility.bind(this));
    }
    ActiveAbilityLabel.prototype.OnClickActiveAbility = function () {
        // 发送事件到服务器
        // $.Msg("sending to server", this.name, this.owner);
        GameEvents.SendCustomGameEventToServer("ds_player_click_active_ability", {
            AbilityName: this.name,
            Owner: this.owner
        });
    };
    return ActiveAbilityLabel;
}());
var TooltipCard = (function (_super) {
    __extends(TooltipCard, _super);
    function TooltipCard(parent, id, uniqueId, cardType, cardData, owner) {
        _super.call(this, parent, id, cardType, cardData);
        this.owner = owner;
    }
    TooltipCard.prototype.UpdateCardMessage = function () {
        $.Msg("updating tooltip card message");
        _super.prototype.UpdateCardMessage.call(this);
        // this.panel.FindChildTraverse("CardDescription").text = "";
        var abilities = this.cardData.abilities;
        var abilities_container = this.panel.FindChildTraverse("CardAbilities");
        abilities_container.RemoveAndDeleteChildren();
        if (abilities !== undefined) {
            for (var aid in abilities) {
                var ability_data = JSON.parse(abilities[aid]);
                if (ability_data == null || this.owner == undefined)
                    continue;
                if (ability_data.type == "active" && Entities.GetTeamNumber(this.owner) == Players.GetTeam(Players.GetLocalPlayer())) {
                    var ability_label = new ActiveAbilityLabel(ability_data.name, abilities_container, this.owner);
                }
                else {
                    var ability_label = $.CreatePanel("Label", abilities_container, "");
                    ability_label.text = $.Localize("Ability_" + ability_data["name"]);
                    ability_label.AddClass("text-h3");
                }
            }
        }
    };
    return TooltipCard;
}(Card));
