function Exp = PrepareExpText(Exp)

if Exp.Flags.EYETRACK
    Exp.Text.startingMsg='Vous allez passer une exp�rience d''oculom�trie.\n\nAvant de commencer l''exp�rience\n\nnous allons r�gler l''oculom�tre.\n\nVous devez pour cela placer\n\nvotre t�te sur le support devant vous.\n\n\nUne fois les r�glages effectu�s,\n\nvous ne devez plus bouger votre t�te\n\navant la fin de l''exp�rience.\n\n\nNe faites surtout pas de mouvement brusque !\n\n\nAppuyez pour continuer.';
else
    Exp.Text.startingMsg='Vous allez passer une exp�rience.\n\n\nAppuyez pour continuer.';
end
Exp.Text.trackerSetupMsg='Durant la phase de calibration l''exp�rimentateur va r�gler les\n\ncam�ras pour obtenir de ''belles'' images de vos yeux.\n\n\nVous devrez suivre un point gris\n\nqui appara�tra au centre de\n\nl''�cran, puis dans diff�rentes positions sur l''�cran.\n\nSuivez ce point sans cligner des yeux\n\net sans anticiper sa position !\n\n\n\nUne fois la calibration termin�e,\n\nil est imp�ratif de ne plus bouger\n\nla t�te�!\n\n\nAppuyez pour continuer.';
Exp.Text.learningMsg='Nous allons commencer par\n\nune phase d''apprentissage pour vous\n\nfamiliariser avec l''exp�rience.';
Exp.Text.driftCorrectionMsg='Lancement d''un drift de correction:\n\nfixer le point blanc sans cligner des yeux.';
Exp.Text.testingMsg='Nous allons maintenant commencer l''exp�rience.\n\nBougez le moins possible !';
Exp.Text.endingMsg='Merci de votre participation !';
Exp.Text.readyMsg='Appuyez sur espace quand vous �tes pr�t.';
% Exp.Text.taskMsg= tsktxt;
Exp.Text.seqEndMsg='Fin de s�quence';
Exp.Text.blockEndMsg='Fin du block';

Exp.Text.taskMsg.Baseline = 'Maintenez le regard sur le point de fixation central.\n Rapportez le percept que vous voyez � l''aide des fl�ches du clavier'; %'Consigne BASELINE';
Exp.Text.taskMsg.Switch = 'Maintenez le regard sur le point de fixation central.\n Essayez de changer le percept que vous voyez le plus rapidement possible \n et rapportez ce percept � l''aide des fl�ches du clavier';%'Consigne SWITCH';
Exp.Text.taskMsg.Hold = 'Maintenez le regard sur le point de fixation central.\n Essayez de maintenir le percept que vous voyez le plus longtemps possible \n et rapportez ce percept � l''aide des fl�ches du clavier';%'Consigne HOLD';
Exp.Text.taskMsg.LJ = 'Consigne LJ';
end
