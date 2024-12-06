import { Controller } from "@hotwired/stimulus"
import { Client } from "@gradio/client";

// Connects to data-controller="record"
export default class extends Controller {

  static targets = [
    'description', 'fileId', 'pictureData', 'pictureDisplayUrl', 'recognitionButton', 'knowledgeDialog'
  ]

  connect() {
  }

  audioSourceTypeChanged() {
    var selectedRadio = document.querySelector('input[name="record[audio_source_type]"]:checked');
    ['upload', 'record'].forEach(function(item) {
      var itemArea = document.getElementById(item + "_area")
      selectedRadio.value == item ? itemArea.classList.remove('d-none') : itemArea.classList.add('d-none')
    });
    const uploadAudioInput = document.getElementById('upload_audio_data');
    const recordAudioInput = document.getElementById('record_audio_data');
    uploadAudioInput.value = null;
    recordAudioInput.value = null;
    document.getElementById('audioPlayback').src = '';
  }

  // 音频识别
  async speechRecognition() {
    // 将识别按钮变为识别中，且不能点击
    this.disableRecognitionButton();
    var selectedRadio = document.querySelector('input[name="record[audio_source_type]"]:checked');
    // 先上传音频文件
    var fileInput = document.getElementById(selectedRadio.value + '_audio_data');
    if (fileInput.files.length == 0) {
        alert("请先输入音频！");
        this.enableRecognitionButton();
        return;
    }
    var file = fileInput.files[0];
    try {
      // 上传音频到文件服务器
      const data = await this.uploadFile(file);
      // 音频在文件服务器的id
      var fileId = data.uid;
      this.fileIdTarget.value = fileId;
      // 然后调用语音识别服务
      var url = window.FILE_CENTER_SERVICE_HOST + "/file_records/" + fileId;
      const response_0 = await fetch(url);
      const audio = await response_0.blob();
      const client = await Client.connect(window.AUDIO_RECOGNITION_SERVICE_HOST);
      const result = await client.predict("/model_inference", {
        input_wav: audio, 		
        language: "auto",
      });
      // 将识别的结果填入描述框
      this.descriptionTarget.value = result.data;
    } finally {
      // 识别完毕后将识别按钮还原
      this.enableRecognitionButton();
    }
  }

  // 录音
  async recording() {
    var stream;
    try {
      stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    } catch (error) {
      // 用户拒绝了权限或发生了错误
      console.error('无法访问麦克风:', error);
      // 错误信息可能会包含 "NotAllowedError", "NotFoundError", "NotAllowedError: Permission denied", 等
      alert('无法访问麦克风，请检查浏览器权限设置');
    };
    const mediaRecorder = new MediaRecorder(stream);
    const audioChunks = [];
    const startBtn = document.getElementById('startBtn');
    const stopBtn = document.getElementById('stopBtn');
    const audioPlayback = document.getElementById('audioPlayback');
    const recordAudioInput = document.getElementById('record_audio_data');

    mediaRecorder.ondataavailable = event => {
        audioChunks.push(event.data);
    };

    mediaRecorder.onstop = () => {
      const audioBlob = new Blob(audioChunks, { 'type': 'audio/wav' });
      const fileName = (new Date()).getTime() + '.wav';
      const file = new File([audioBlob], fileName, { 'type': 'audio/wav' });
      const audioUrl = URL.createObjectURL(audioBlob);
      const dataTransfer = new DataTransfer()
      audioPlayback.src = audioUrl;
      dataTransfer.items.add(file);
      recordAudioInput.files = dataTransfer.files;
      startBtn.classList.remove('d-none');
      stopBtn.classList.add('d-none');
    };

    startBtn.classList.add('d-none');
    stopBtn.classList.remove('d-none');
    mediaRecorder.start();

    document.getElementById('stopBtn').addEventListener('click', () => {
      mediaRecorder.stop();
    });
  }

  // 上传图片到文件服务器
  async uploadPicture() {
    var file = this.pictureDataTarget.files[0];
    if (!file) {
      this.pictureDisplayUrlTarget.classList.add('d-none');
      return;
    }
    const data = await this.uploadFile(file);
    this.fileIdTarget.value = data.uid;
    this.pictureDisplayUrlTarget.src = window.FILE_CENTER_SERVICE_HOST + '/file_records/' + data.uid; 
    this.pictureDisplayUrlTarget.classList.remove('d-none');
  }

  // 上传文件到文件服务器
  async uploadFile(file) {
    var formData = new FormData();
    formData.append('file', file);
    const uploadResult = await fetch(window.FILE_CENTER_SERVICE_HOST + '/file_records', {
        method: 'POST',
        body: formData
    });
    const data = await uploadResult.json();
    return data;
  }

  // 激活识别按钮
  enableRecognitionButton() {
    this.recognitionButtonTarget.innerText = '识别';
    this.recognitionButtonTarget.disabled = false;
  }

  // 禁用识别按钮
  disableRecognitionButton() {
    this.recognitionButtonTarget.innerText = '识别中';
    this.recognitionButtonTarget.disabled = true;
  }

  // 打开知识来源的dialog
  openKnowledgeDialog() {
    this.knowledgeDialogTarget.classList.remove('d-none');
  }

}
