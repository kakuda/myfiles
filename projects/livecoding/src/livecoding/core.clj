(ns livecoding.core
  (:use [overtone.live]))

(defsynth ikeda [phase 0 gt 1 amp 0.1]
  (let [vals (dwhite 0.01 0.1 INF)
        in-array (repeatedly 20 #(rand-nth (range 10 10000)))
        oscs (vec (map #(sin-osc % phase) in-array))
        spr (splay oscs :spread 0.1 :level 1.0 :center 0.0)]
    (free-self (- 1 gt))
    (out 0 (* spr amp))))

(ikeda 0 0.1 0.1)
(ikeda :phase (/ Math/PI 2) :gt 0.1 :amp 0.1)

(defsynth splay-test [note 52]
  (let [freq (midicps 52)
        waves (saw [freq (* 1.5 freq)])
        snd (splay waves :spread 0.1 :level 0.1 :center -0.75)]
    (out 0 snd)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(definst kick [freq 120 dur 0.3 width 0.7]
  (let [freq-env (* freq (env-gen (perc 0 (* 0.99 dur))))
        env (env-gen (perc 0.01 dur) 1 1 0 1 FREE)
        sqr (* (env-gen (perc 0 0.01)) (pulse (* 2 freq) width))
        src (sin-osc freq-env)
        drum (+ sqr (* env src))]
    (compander drum drum 0.2 1 0.1 0.01 0.01)))

; (kick)

(definst c-hat [amp 0.6 t 0.04]
  (let [env (env-gen (perc 0.001 t) 1 1 0 1 FREE)
        noise (white-noise)
        sqr (* (env-gen (perc 0.01 0.04)) (pulse 000 0.2))
        filt (bpf (+ sqr noise) 0000 0.5)]
    (* amp env filt)))

; (c-hat)

(def metro (metronome 110))

(def k (list 0.25 0.5))
(defn k-loop [beat]
  (let [dur (rand-nth k)]
    (at (metro beat) (kick))
    (apply-at (metro (+ beat dur)) #'k-loop (+ beat dur) [])))

(defn r-loop [beat]
  (let [dur 0.5]
    (at (metro beat) kick)
    (at (metro (+ beat 0.5)) (snare))
    (apply-at (metro (+ beat dur)) #'r-loop (+ beat dur) [])))

(defn hat-loop [beat]
  (at (metro beat) (c-hat))
  (apply-at (metro (+ beat 0.25)) #'hat-loop (+ beat 0.25) []))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(def b1 (scale :d2 :dorian))

(definst bass [freq 440 amp 0.5]
  (let [env (env-gen (perc 0 0.5 1) 1 1 0 1 FREE)
        src (saw freq)
        src2 (blip freq)]
    (* env (+ src src2) amp)) 30 3000)

(defsynth tb303 [note 60 wave 1
                 cutoff 100 r 0.9
                 attack 0.101 decay 1.0 sustain 0.2 release 0.2
                 env 200 gate 0 vol 0.0]
  (let [freq (midicps note)
        freqs [freq (* 1.01 freq)]
        vol-env (env-gen (adsr attack decay sustain release)
                         (line:kr 1 0 (+ attack decay release))
                         :action FREE)
        fil-env (env-gen (perc))
        fil-cutoff (+ cutoff (* env fil-env))
        waves [(* vol-env (saw freqs))
               (* vol-env [(pulse (first freqs) 0.5) (lf-tri (second freqs))])]]
    (out 0 (* [vol vol] (rlpf (select wave (apply + waves)) fil-cutoff r)))))

(defn bass-loop [beat]
  (let [dur (rand-nth k)
        nt (rand-nth b1)]
    (at (metro beat) (bass (midi->hz nt)))
    ;;(at (metro beat) (tb303 :wave 1 :note nt :vol 0.2 :cutoff 10000 :r 0.9 :gate 1 :env 100 :decay 0.1))
    (apply-at (metro (+ beat dur)) #'bass-loop (+ beat dur) [])))

(definst s [freq 440 amp 0.2]
  (let [env (env-gen (perc 0 0.5 1) 1 1 0 1 FREE)
        src (saw freq)
        src2 (white-noise)]
    (* env src amp)))

(defn s-loop [beat]
  (let [dur (rand-nth k)
        dm7 (rand-chord :d4 :m7 4 24)
        chd dm7]
    (doseq [c chd]
      (at (metro beat) (s (midi->hz c))))
    (apply-at (metro (+ beat dur)) #'s-loop (+ beat dur) [])))
