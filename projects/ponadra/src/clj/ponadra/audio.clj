(ns ponadra.audio
  (:use [clojure.java.io])
  (:import [net.sourceforge.jaad.aac Decoder SampleBuffer]
           [net.sourceforge.jaad.mp4 MP4Container]
           [net.sourceforge.jaad.mp4.api AudioTrack$AudioCodec Frame Movie Track]
           [java.io File FileInputStream RandomAccessFile]))


(defn m4a-to-raw [path]
  (let [cont (MP4Container. (RandomAccessFile. path "r"))
        movie (.getMovie cont)
        tracks (.getTracks movie AudioTrack$AudioCodec/AAC)
        track (first tracks)
        dec (Decoder. (.getDecoderSpecificInfo track))
        buf (SampleBuffer.)]
    (with-open [w (make-output-stream "out.raw" {})]
      (loop []
        (when (.hasMoreFrames track)
          (.decodeFrame dec (.getData (.readNextFrame track)) buf)
          (.write w (.getData buf))
          (recur))))))
    ;; {:sample-rate (.getSampleRate track)
    ;;  :channel-count (.getChannelCount track)
    ;;  :sample-size (.getSampleSize track)}))
