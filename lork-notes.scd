// MAPPING


/*

We need to come put with some synths that use an X-factor.  This number will always be between 0-1, so if we want to use numbers bigger or smaller than that, we'll have to scale (or map) the number.

*/

(
var freq;

x = 0.5;
freq = x.linexp(0, 1, 20, 20000);

)

/*

linexp takes a number that varies linearly (such as X) and maps it to an exponential number.  Because frequencies double per octace, it is an example of an exponential number.  In the exmaple above, we map x to the limits of human hearing.

The first argument, 0, is the lowest value of x
The second argument, 1, is the higest value of x
(those numbers describe X for this piece, so we shouldn't change them)

The third number, 20, describes the lowest number we want to get out of out mapping. We *can* change this.
The fourth number, 2000, describes the highest number we want to get out of our mapping. We can also change this.

Because of the way exponential numbers work, 0 CANNOT be in out range out output numbers. Both the third and the fourth arguments must be on the same size of 0.

*/

(
var e1, e2, e3;

x = 0.5;

e1 = x.linexp(0, 1, 200, 2000); // this is good
e2 = x.linexp(0, 1, -200, -2000); // this is also good
e3 = x.linexp(0, 1, -200, 2000); // this is BAD

)


/*
We can also map x linearly
*/


(

var dur;

x = 0.5;

dur = x.linlin(0, 1, 0.1, 2);

)

/*

The first argument, 0, is the lowest value of x
The second argument, 1, is the higest value of x
(those numbers describe X for this piece, so we shouldn't change them)

The third number, 0.1, describes the lowest number we want to get out of out mapping. We *can* change this.
The fourth number, 2, describes the highest number we want to get out of our mapping. We can also change this.

with linear numbers, it's totally fine to have a 0 in the output range.

*/


(

var l1, l2, l3;

x = 0.5;

// All of these are fine:
l1 = x.linlin(0, 1, 0.1, 2);
l2 = x.linlin(0, 1, -0.1, -2);
l3 = x.linlin(0, 1, -0.1, 2);
)




/*
If we want to use our X to control two different parameters, we just need to map it twice.

*/

(
var dur, freq;

x = 0.5;

dur = x.linlin(0, 1, 0.1, 2);
freq = x.linexp(0, 1, 200, 1900);

)




// SOUNDS

/* Now that we know how to map the X, what are some things we could do?

Let's test some stuff.  Don't forget to turn up your amp if you want to hear anything.
*/



/*
FM
*/


(

s.waitForBoot({
	SynthDef(\stuck, {|x, amp, gate|
		var freq, sound, env;

		// using X for low-ish frequency
		freq = x.linexp(0, 1, 20, 180);


		sound = SinOsc.ar(
			SinOsc.ar(freq, 0, 600), // We are varying the modulator's frequency
			0, amp);





		env = EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(0, sound * env)
	}).add;

	s.sync;


	n = StuckNote.new.test

})

)



/*

RM

*/


(

s.waitForBoot({
	SynthDef(\stuck, {|x, amp, gate|
		var freq, sound, env;

		// using X for mid-range frequency
		freq = x.linexp(0, 1, 200, 1000);


		sound = SinOsc.ar(30, 0, amp) *
		SinOsc.ar(freq, 0, 1); // We are varying only 1 frequency





		env = EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(0, sound * env)
	}).add;

	s.sync;


	n = StuckNote.new.test

})

)

/*
Slow AM
*/

(

s.waitForBoot({
	SynthDef(\stuck, {|x, amp, gate|
		var dur, sound, env;

		// using X for duration
		dur = x.linexp(0, 1, 0.1, 1);


		sound = SinOsc.ar(300, 0, amp) *
		LFPulse.ar(1/dur); // The frequency is the reciprocal of the duration
		// FLPulse goes between 0-1




		env = EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(0, sound * env)
	}).add;

	s.sync;


	n = StuckNote.new.test

})

)

/*
If you use an oscillator that goes between -1 to 1, you will need to map it to do AM:
*/

(

s.waitForBoot({
	SynthDef(\stuck, {|x, amp, gate|
		var freq, sound, env;

		// using X for frequency
		freq = x.linexp(0, 1, 200, 1000);


		sound = SinOsc.ar(30, 0, amp) *
		SinOsc.ar(freq).linlin(-1, 1, 0, 1); // Map this for AM so it is between 0 and 1





		env = EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(0, sound * env)
	}).add;

	s.sync;


	n = StuckNote.new.test

})

)


/*
Some things you might want to try out:

Use different Oscillators:
Blip
Formant
Pulse
Saw
Klank

...look at the help files for those

Use filters:
RLPF
RHPF
Comb

Use X to control more than one thing!

*/

// If you want do use X 'backwards' so a higher number does down and a lower number goes up

(
var backwards, freq;
x = 0.5;

backwards = (x-1).abs;
freq = backwards.linexp(0, 1, 100, 900);
)


// x-1 goes between -1 to 0
// abs is the absolute value
// -1.abs = 1
// 0.abs = 0
// therefore (x-1).abs goes from 1 to 0


/*
The file lork.scd has just the template for your synthdef and none of the rest of these notes.
*/