<!-- https://wavesurfer-js.org -->
<template>
    <div class="container">
        <div id="demo">
            <div id="waveform" style="position:relative">
            </div>
            <div id="wave-timeline"></div>
        </div>
        <div v-if="additionalData && additionalData.showPlaybackRate == true" style="text-align: center" class="mt-3">
            <button :title="additionalData.playerHotKey ? $genHotKeyStr(additionalData.playerHotKey.PLAYBACK_SPEED_HALF) : ''" :class="playbackSpeedRate == '0.82' ? '':'btn-grey'" class="btn btn-sm btn-primary" @click="setWSPlaybackRate(0.82)" style="padding: 2px 12px">0.5</button>
            <button :title="additionalData.playerHotKey ? $genHotKeyStr(additionalData.playerHotKey.PLAYBACK_SPEED_NORMAL) : ''"  :class="playbackSpeedRate == 1 ? '':'btn-grey'" class="btn btn-sm btn-primary" @click="setWSPlaybackRate(1)" style="padding: 2px 12px">1x</button>
        </div>
    </div>
</template>
<script> 
let WaveSurfer = require('../../../../public/assets/plugins/wavesurfer/wavesurfer.js')
let TimelinePlugin = require('../../../../public/assets/plugins/wavesurfer/wavesurfer.timeline.js')
let WaveSurferCursor = require('../../../../public/assets/plugins/wavesurfer/wavesurfer.cursor.js')
let WaveSurferRegions = require('../../../../public/assets/plugins/wavesurfer/wavesurfer.regions.js')
export default{
    data() {
        return {
            wavesurfer:{},
            playbackSpeedRate:1
        }
    },
    props:['compId','options', 'timelineOptions','additionalData'],
    mounted() {
        this.initWSPlayer(this.options);
    },
    methods: {
        initWSPlayer(options){ 
            let self = this;
            let comId = this.compId ? '#'+this.compId : ''; 
            let timelineConfig = {
                container: comId+' #wave-timeline',
                height: 15
            };
            let regionsConfig = {
                regions: [
                    {
                        loop: false,
                        color: 'hsla(400, 100%, 30%, 0.5)'
                    }
                ],
                dragSelection: {
                    slop: 5
                },
                maxRegions: 3,
            };
            let cursorConfig = {
                showTime: false,
                opacity: 1,
                customShowTimeStyle: {
                    'background-color': '#000',
                    color: '#fff',
                    padding: '2px',
                    'font-size': '12px'
                }
            };

            $.extend(true, timelineConfig, self.timelineOptions);
            let plugins = [TimelinePlugin.create(timelineConfig)];

            if(self.additionalData && self.additionalData.audioCropEnable == true){
                plugins.push(WaveSurferRegions.create(regionsConfig));
            }

            if(self.additionalData && self.additionalData.cursorEnable == true){
                plugins.push(WaveSurferCursor.create(cursorConfig));
            }
            let config = {
                container: comId+' #waveform',
                waveColor: '#7796ff',
                progressColor: '#2b51d0',
                loaderColor: '#2b51d0',
                cursorColor: 'purple',
                height: 80,
                plugins: plugins
            };
            $.extend(true, config, options);
            this.wavesurfer = WaveSurfer.create(config);
        },
        wsInstance(){
            return this.wavesurfer;
        },
        /**
         * play audio file list
         * @param string playList 
         * @param boolean reload 
         */
        playWSPlayer(playList, reload = true){ 
            let self = this;
            let currentDuration = this.wavesurfer.getCurrentTime(); 
            let totalDuration = this.wavesurfer.getDuration(); 
            let duration = currentDuration == totalDuration ? 0 : currentDuration;
            // reload for first time
            if(reload){
                // load audio
                this.wavesurfer.load(playList);
                this.wavesurfer.on('ready', function () {
                    self.wavesurfer.play();
                });
            }else{ 
                self.wavesurfer.play(duration);
            }
            
        },
        /**
         * pause audio
         */
        pauseWSPlayer(){ 
            let self = this;
            if(self.wavesurfer.isPlaying() == true ){
                self.wavesurfer.pause();
            }
            
        },
        /**
         * stop audio
         */
        stopWSPlayer(){ 
            let self = this;
            self.wavesurfer.stop();
        },
        /**
         * play/pause audio
         */
        playPauseWSPlayer(playList){
            let self = this;
            this.wavesurfer.load(playList);
            this.wavesurfer.on('ready', function () {
               self.wavesurfer.playPause();
            });
            
        },
        destroyWSPlayer(){
            this.wavesurfer.destroy();
        },
        setWSPlaybackRate(rate){
            this.playbackSpeedRate = rate;
            this.wavesurfer.setPlaybackRate(rate);
        }

    },
};
</script>
