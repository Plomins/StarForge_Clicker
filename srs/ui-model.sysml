package StarForgeClicker {
    public import ScalarValues::*;

    // =========================================================================
    // 1. ПЕРЕЧИСЛЕНИЯ СОСТОЯНИЙ СИСТЕМЫ И UI (ENUMERATIONS)
    // =========================================================================
    
    enum def ScreenState {
        enum mainForgeView;
        enum upgradesPanelView;
        enum prestigeGalaxyView;
        enum achievementsView;
        enum settingsModalView;
        enum offlineRewardModalView;
    }

    enum def StarEvolutionStage {
        enum protostar;
        enum mainSequenceStar;
        enum redGiant;
        enum supernovaCore;
        enum neutronPulsar;
        enum quasarForge;
    }

    enum def UpgradeAvailability {
        enum locked;
        enum visibleUnavailable;
        enum affordable;
        enum maxedOut;
    }

    enum def BuyMultiplierMode {
        enum buy1x;
        enum buy10x;
        enum buy100x;
        enum buyMax;
    }

    enum def ThemeStyle {
        enum deepSpaceDark;
        enum nebulaGlass;
        enum highContrast;
    }

    // =========================================================================
    // 2. РАСШИРЕННАЯ МОДЕЛЬ ПОЛЬЗОВАТЕЛЬСКОГО ИНТЕРФЕЙСА (UI MODEL)
    // =========================================================================

    package UIModel {
        
        // Базовые компоненты GUI
        part def UIWidget {
            attribute widgetId : String;
            attribute isVisible : Boolean default true;
            attribute isEnabled : Boolean default true;
            attribute posX : Integer;
            attribute posY : Integer;
            attribute width : Natural;
            attribute height : Natural;
        }

        part def UIButton :> UIWidget {
            attribute labelText : String;
            attributehotkey : String;
            attribute responseTimeMs : Natural default 16;
        }

        part def UICounterLabel :> UIWidget {
            attribute title : String;
            attribute formattedValue : String;
            attribute unitSuffix : String;
        }

        part def UIProgressBar :> UIWidget {
            attribute currentValue : Real default 0.0;
            attribute maxValue : Real default 100.0;
            attribute fillColorHex : String;
        }

        part def UIToggleSwitch :> UIWidget {
            attribute label : String;
            attribute isChecked : Boolean default true;
        }

        part def UISlider :> UIWidget {
            attribute minValue : Natural default 0;
            attribute maxValue : Natural default 100;
            attribute currentValue : Natural default 80;
        }

        // Карточка улучшения / авто-генератора в списке
        part def UpgradeCardWidget :> UIWidget {
            attribute upgradeId : String;
            attribute title : String;
            attribute level : Natural default 0;
            attribute currentCost : Real;
            attribute productionBonus : Real;
            attribute state : UpgradeAvailability;

            part buyButton : UIButton;
            part iconBadge : UIWidget;
            part costLabel : UICounterLabel;
            part bonusLabel : UICounterLabel;
        }

        // Верхняя панель показателей (HUD)
        part def TopHudBar :> UIWidget {
            part stardustBalanceCounter : UICounterLabel;
            part stardustPerSecondLabel : UICounterLabel;
            part stardustPerClickLabel : UICounterLabel;
            part darkMatterBadge : UICounterLabel;
            part openSettingsButton : UIButton;
            part openStatsButton : UIButton;
            part quickSaveIndicator : UIWidget;
        }

        // Центральная интерактивная область клика (Кузница Звезды)
        part def StarCoreViewport :> UIWidget {
            attribute currentStage : StarEvolutionStage;
            attribute activeFps : Natural default 60;
            attribute particleEffectsEnabled : Boolean default true;

            part interactiveStarButton : UIButton;
            part comboMultiplierBar : UIProgressBar;
            part evolutionStageProgressBar : UIProgressBar;
            part floatingDamageOverlay : UIWidget;
            part stageTitleLabel : UICounterLabel;
        }

        // Боковая панель улучшений, генераторов и навигации
        part def UpgradesAndGeneratorsSidebar :> UIWidget {
            attribute selectedMultiplier : BuyMultiplierMode;

            part tabClickUpgradesButton : UIButton;
            part tabAutoGeneratorsButton : UIButton;
            part tabPrestigeButton : UIButton;
            part tabAchievementsButton : UIButton;
            part multiplierSelectorButton : UIButton;
            part searchFilterBox : UIWidget;
            part upgradeCards[1..20] : UpgradeCardWidget;
        }

        // Модальное окно Престижа (Галактический сброс)
        part def PrestigeModalDialog :> UIWidget {
            attribute pendingDarkMatterReward : Real;
            attribute currentGlobalMultiplier : Real;

            part currentDarkMatterLabel : UICounterLabel;
            part rewardPreviewLabel : UICounterLabel;
            part confirmAscensionButton : UIButton;
            part cancelModalButton : UIButton;
            part prestigePerkNodes[1..10] : UpgradeCardWidget;
        }

        // Модальное окно оффлайн-дохода
        part def OfflineEarningsDialog :> UIWidget {
            attribute offlineDurationSeconds : Natural;
            attribute accumulatedStardust : Real;

            part timeAwayLabel : UICounterLabel;
            part earnedAmountLabel : UICounterLabel;
            part collectRewardButton : UIButton;
        }

        // Модальное окно настроек и управления сохранениями
        part def SettingsModalDialog :> UIWidget {
            attribute activeTheme : ThemeStyle;

            part masterVolumeSlider : UISlider;
            part sfxVolumeSlider : UISlider;
            part particlesToggle : UIToggleSwitch;
            part floatingTextToggle : UIToggleSwitch;
            part scientificNotationToggle : UIToggleSwitch;
            part exportSaveButton : UIButton;
            part importSaveButton : UIButton;
            part wipeSaveButton : UIButton;
            part closeSettingsButton : UIButton;
        }

        // Главный контейнер пользовательского интерфейса
        part def UserInterface {
            attribute currentScreen : ScreenState;
            attribute currentTheme : ThemeStyle;
            attribute windowWidth : Natural default 1280;
            attribute windowHeight : Natural default 720;

            part hudBar : TopHudBar;
            part starViewport : StarCoreViewport;
            part sidebar : UpgradesAndGeneratorsSidebar;
            part prestigeModal : PrestigeModalDialog;
            part offlineDialog : OfflineEarningsDialog;
            part settingsModal : SettingsModalDialog;

            // Внутренние навигационные связи UI
            connect hudBar.openSettingsButton to settingsModal;
            connect sidebar.tabPrestigeButton to prestigeModal;
            connect starViewport.interactiveStarButton to hudBar.stardustBalanceCounter;
            connect sidebar.upgradeCards to hudBar.stardustPerSecondLabel;
        }
    }

    // =========================================================================
    // 3. СТРУКТУРА ДОМЕННОЙ ЛОГИКИ И СИСТЕМЫ (SYSTEM ARCHITECTURE)
    // =========================================================================

    part def Player;

    part def GeneratorItem {
        attribute id : String;
        attribute name : String;
        attribute baseCost : Real;
        attribute costGrowthFactor : Real default 1.15;
        attribute baseProductionPerSec : Real;
        attribute ownedCount : Natural default 0;
    }

    part def ClickEngine {
        attribute baseClickPower : Real default 1.0;
        attribute critChancePercent : Real default 5.0;
        attribute critMultiplier : Real default 2.0;
        attribute comboBonusMultiplier : Real default 1.0;
    }

    part def IdleEconomyEngine {
        attribute stardustBalance : Real default 0.0;
        attribute stardustPerSecond : Real default 0.0;
        attribute tickIntervalMs : Natural default 100;
        attribute maxOfflineHours : Natural default 24;
        part generators[1..10] : GeneratorItem;
    }

    part def PrestigeManager {
        attribute darkMatterCount : Real default 0.0;
        attribute prestigeBonusPercent : Real default 10.0;
        attribute totalResetsCount : Natural default 0;
    }

    part def SaveStorageManager {
        attribute autoSaveIntervalSeconds : Natural default 30;
        attribute saveFilePath : String;
        attribute backupEnabled : Boolean default true;
    }

    part def StarForgeApp {
        part ui : UIModel::UserInterface;
        part clickEngine : ClickEngine;
        part economy : IdleEconomyEngine;
        part prestige : PrestigeManager;
        part storage : SaveStorageManager;

        // Связи между UI и подсистемами приложения
        connect ui.starViewport to clickEngine;
        connect ui.sidebar to economy;
        connect ui.hudBar to economy;
        connect ui.prestigeModal to prestige;
        connect ui.offlineDialog to economy;
        connect ui.settingsModal to storage;
        connect clickEngine to economy;
        connect prestige to economy;
        connect economy to storage;
    }

    part starForgeClicker : StarForgeApp;

    // =========================================================================
    // 4. ПРЕЦЕДЕНТЫ ИСПОЛЬЗОВАНИЯ (USE CASES)
    // =========================================================================

    use case def MineStardustByClicking {
        subject app : StarForgeApp;
        actor player : Player;
    }

    use case def PurchaseUpgradesAndGenerators {
        subject app : StarForgeApp;
        actor player : Player;
    }

    use case def PerformGalacticPrestige {
        subject app : StarForgeApp;
        actor player : Player;
    }

    use case def ManageSettingsAndSaves {
        subject app : StarForgeApp;
        actor player : Player;
    }

    // =========================================================================
    // 5. ТРЕБОВАНИЯ (REQUIREMENTS)
    // =========================================================================

    package Requirements {
        
        requirement def UIResponsivenessReq {
            doc /* Интерфейс должен обрабатывать клики и отображать отклик не дольше 16 мс (60 FPS) */
            attribute maxResponseMs : Natural default 16;
        }

        requirement def TwoClicksAccessReq {
            doc /* Переход к покупке любого улучшения, престижу или настройкам не более чем за 2 клика */
            attribute maxClicks : Natural default 2;
        }

        requirement def MemoryLimitReq {
            doc /* Потребление оперативной памяти приложением не должно превышать 512 МБ */
            attribute maxMemoryMB : Natural default 512;
        }

        requirement def AutoSaveReliabilityReq {
            doc /* Автоматическое сохранение прогресса каждые 30 секунд и при закрытии окна */
            attribute saveIntervalSeconds : Natural default 30;
        }

        requirement def OfflineProgressionReq {
            doc /* Расчёт пассивного дохода за время отсутствия игрока до 24 часов */
            attribute maxOfflineHours : Natural default 24;
        }

        requirement <'REQ-INT-001'> uiResponsiveness : UIResponsivenessReq;
        requirement <'REQ-INT-002'> twoClicksNavigation : TwoClicksAccessReq;
        requirement <'REQ-PERF-001'> memoryLimit : MemoryLimitReq;
        requirement <'REQ-REL-001'> autoSave : AutoSaveReliabilityReq;
        requirement <'REQ-FUNC-008'> offlineEarnings : OfflineProgressionReq;
    }
}
