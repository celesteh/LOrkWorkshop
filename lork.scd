
(

s.waitForBoot({
	SynthDef(\stuck, {|x, amp, gate|
		var freq, sound, env;

		// using X for frequency (you can use it for something else. See lork-notes.scd)
		freq = x.linexp(0, 1, 20, 20000);


		// put your sound here!
		sound = SinOsc.ar(freq, 0, amp);





		env = EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(0, sound * env)
	}).add;

	s.sync;


	//StuckNote.new.test
	StuckNote.new

})

)

//OSCdef.trace