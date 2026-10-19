package StarForgeClickerUI {
    part def Screen;
    part def Button;
    part def Label;
    part def ProgressBar;

    part mainScreen : Screen {
        part menuTabs : Button[4];            // Игра, Улучшения, Достижения, Настройки
        part dustLabel : Label;               // Звёздная пыль
        part statsLabel : Label;              // доход/сек, сила клика, уровень
        part clickButton : Button;            // главный объект клика
        part quickBuyList : Button[3];        // быстрая покупка
        part xpBar : ProgressBar;
    }
    part upgradesScreen : Screen {
        part dustLabel : Label;
        part upgradeRows : Button[5];         // кнопка «Купить» в каждой строке
    }
    part achievementsScreen : Screen {
        part counterLabel : Label;            // получено X из N
        part achievementCards : Label[12];
    }

    connection navigation connect mainScreen.menuTabs to upgradesScreen;
}
