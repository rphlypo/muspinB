function Exp = PrepareExpText(Exp)

if Exp.Flags.EYETRACK
    Exp.Text.startingMsg='Vous allez passer une experience d''oculometrie.\n\nAvant de commencer l''experience\n\nnous allons regler l''oculometre.\n\nVous devez pour cela placer\n\nvotre tete sur le support devant vous.\n\n\nUne fois les reglages effectues,\n\nvous ne devez plus bouger votre tete\n\navant la fin de l''experience.\n\n\nNe faites surtout pas de mouvement brusque !\n\n\nAppuyez pour continuer.';
    Exp.Text.driftCorrectionMsg='Lancement d''un drift de correction:\n\nfixer le point blanc sans cligner des yeux.';
else
    Exp.Text.startingMsg='Vous allez passer une experience.\n\n\nAppuyez pour continuer.';
end
Exp.Text.trackerSetupMsg='Durant la phase de calibration l''experimentateur va regler les\n\ncameras pour obtenir de ''belles'' images de vos yeux.\n\n\nVous devrez suivre un point gris\n\nqui apparaitra au centre de\n\nl''ecran, puis dans differentes positions sur l''ecran.\n\nSuivez ce point sans cligner des yeux\n\net sans anticiper sa position !\n\n\n\nUne fois la calibration terminee,\n\nil est imperatif de ne plus bouger\n\nla tete?!\n\n\nAppuyez pour continuer.';
Exp.Text.learningMsg='Nous allons commencer par\n\nune phase d''apprentissage pour vous\n\nfamiliariser avec l''experience.';
Exp.Text.testingMsg='Nous allons maintenant commencer l''experience.\n\nBougez le moins possible !';
Exp.Text.endingMsg='Merci de votre participation !';
Exp.Text.readyMsg='Appuyez sur espace quand vous etes pret.';
% Exp.Text.taskMsg= tsktxt;
Exp.Text.seqEndMsg='Fin de sequence';
Exp.Text.blockEndMsg='Fin du block';

if strcmp(Exp.Type, 'GazeEEG')
    Exp.Text.taskMsg.AmbKp = '';
    Exp.Text.taskMsg.nAmbKp = '';
    Exp.Text.taskMsg.AmbnKp = '';
    Exp.Text.taskMsg.nAmbnKp = '';
end

if strcmp(Exp.Type, 'TopDown')
    % Exp.Text.taskMsg.BaselineL = 'Maintenez le regard sur le point de fixation central.\n\n Rapportez le percept que vous voyez ? l''aide des fl?ches du clavier'; %'Consigne BASELINE';
    Exp.Text.taskMsg.BaselineL = 'BASELINE LEARN';
    % % Exp.Text.taskMsg.Switch = 'Maintenez le regard sur le point de fixation central.\n Essayez de changer le percept que vous voyez le plus rapidement possible \n et rapportez ce percept ? l''aide des fl?ches du clavier';%'Consigne SWITCH';
    % % Exp.Text.taskMsg.Hold = 'Maintenez le regard sur le point de fixation central.\n Essayez de maintenir le percept que vous voyez le plus longtemps possible \n et rapportez ce percept ? l''aide des fl?ches du clavier';%'Consigne HOLD';
    % Exp.Text.taskMsg.BaselineT = 'Suivez le point de fixation avec la souris le plus pr?s possible.\n\n Rapportez le percept que vous voyez ? l''aide des fl?ches du clavier'; %'Consigne BASELINE';
    Exp.Text.taskMsg.BaselineT = 'BASELINE TEST';
    % Exp.Text.taskMsg.Switch = 'Suivez le point de fixation avec la souris le plus pr?s possible.\n\n Essayez de changer le percept que vous voyez le plus rapidement possible \n\n et rapportez ce percept ? l''aide des fl?ches du clavier';%'Consigne SWITCH';
    Exp.Text.taskMsg.Switch = 'SWITCH';
    % Exp.Text.taskMsg.Hold = 'Suivez le point de fixation avec la souris le plus pr?s possible.\n\n Essayez de maintenir le percept que vous voyez le plus longtemps possible \n\n et rapportez ce percept ? l''aide des fl?ches du clavier';%'Consigne HOLD';
    Exp.Text.taskMsg.Hold = 'HOLD';
    % Exp.Text.taskMsg.LJ = 'Suivez le point de fixation avec la souris le plus pr?s possible. \n\n Ne rapportez pas vos percepts.';%Consigne LJ';
    Exp.Text.taskMsg.LJ = 'LISSAJOU LEARN';
end
if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 1
end
if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2
    Exp.Text.taskMsg.Short = 'Rapportez le percept que vous percevez en appuyant \n\n les touches flechees du clavier. \n\n Gardez votre regard sur le point de fixation au centre.';
    Exp.Text.taskMsg.Long = 'Rapportez le percept que vous percevez en maintenant appuye \n\n les touches flechees du clavier au cours du temps.  \n\n Gardez votre regard sur le point de fixation au centre.';
    Exp.Text.taskMsg.Dynamic = 'Rapportez le percept que vous percevez en maintenant appuye \n\n les touches flechees du clavier au cours du temps.  \n\n Gardez votre regard sur le point de fixation au centre.';
end
if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
    if Exp.Flags.PREPILOT
        switch Exp.EyeLink.PlaidOn
            case '0'
                Exp.Text.taskMsg = 'Maintenez votre regard dans la zone centrale grise.';
            case '1'
                Exp.Text.taskMsg = 'Rapportez le percept que vous percevez en maintenant appuye \n\n les touches flechees du clavier au cours du temps. \n\n Maintenez votre regard dans la zone centrale grise';
        end
    else
        Exp.Text.taskMsg = 'Rapportez le percept que vous percevez en maintenant appuye \n\n les touches flechees du clavier au cours du temps. \n\n Gardez votre regard sur le point de fixation au centre.';
    end
end
if strcmp(Exp.Type, 'AfterEffect') && Exp.Pilot == 2
    Exp.Text.taskMsg = 'Consignes: \n\n Maintenez le regard sur le point de fixation central. \n\n Rapportez la ou les direction(s) de mouvement de la grille \n la plus proche que vous voyez à l''aide des flèches du clavier. \n\n A l''arrêt du stimulus, \n - continuez de rapporter la direction du mouvement avec les flèches du clavier.\n - si vous ne percevez pas ou plus de mouvement, appuyer sur espace. \n\n Appuyez une seconde fois sur espace pour continuer.';
end
end
