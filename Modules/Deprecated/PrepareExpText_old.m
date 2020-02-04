function Exp = PrepareExpText(Exp)

if Exp.Flags.EYETRACK
    Exp.Text.startingMsg='Vous allez passer une expérience d''oculométrie.\n\nAvant de commencer l''expérience\n\nnous allons régler l''oculomètre.\n\nVous devez pour cela placer\n\nvotre tête sur le support devant vous.\n\n\nUne fois les réglages effectués,\n\nvous ne devez plus bouger votre tête\n\navant la fin de l''expérience.\n\n\nNe faites surtout pas de mouvement brusque !\n\n\nAppuyez pour continuer.';
else
    Exp.Text.startingMsg='Vous allez passer une expérience.\n\n\nAppuyez pour continuer.';
end
Exp.Text.trackerSetupMsg='Durant la phase de calibration l''expérimentateur va régler les\n\ncaméras pour obtenir de ''belles'' images de vos yeux.\n\n\nVous devrez suivre un point gris\n\nqui apparaîtra au centre de\n\nl''écran, puis dans différentes positions sur l''écran.\n\nSuivez ce point sans cligner des yeux\n\net sans anticiper sa position !\n\n\n\nUne fois la calibration terminée,\n\nil est impératif de ne plus bouger\n\nla tête !\n\n\nAppuyez pour continuer.';
Exp.Text.learningMsg='Nous allons commencer par\n\nune phase d''apprentissage pour vous\n\nfamiliariser avec l''expérience.';
Exp.Text.driftCorrectionMsg='Lancement d''un drift de correction:\n\nfixer le point blanc sans cligner des yeux.';
Exp.Text.testingMsg='Nous allons maintenant commencer l''expérience.\n\nBougez le moins possible !';
Exp.Text.endingMsg='Merci de votre participation !';
Exp.Text.readyMsg='Appuyez sur espace quand vous êtes prêt.';
% Exp.Text.taskMsg= tsktxt;
Exp.Text.seqEndMsg='Fin de séquence';
Exp.Text.blockEndMsg='Fin du block';

Exp.Text.taskMsg.Baseline = 'Maintenez le regard sur le point de fixation central.\n Rapportez le percept que vous voyez à l''aide des flèches du clavier'; %'Consigne BASELINE';
Exp.Text.taskMsg.Switch = 'Maintenez le regard sur le point de fixation central.\n Essayez de changer le percept que vous voyez le plus rapidement possible \n et rapportez ce percept à l''aide des flèches du clavier';%'Consigne SWITCH';
Exp.Text.taskMsg.Hold = 'Maintenez le regard sur le point de fixation central.\n Essayez de maintenir le percept que vous voyez le plus longtemps possible \n et rapportez ce percept à l''aide des flèches du clavier';%'Consigne HOLD';
Exp.Text.taskMsg.LJ = 'Consigne LJ';
end
