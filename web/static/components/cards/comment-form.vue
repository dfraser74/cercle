<template>
  <div class="card-comments-form">
    <h3 style="color:rgb(99,99,99);font-weight:bold;"><i class="fa fa-fw fa-comments-o"></i>Comments</h3>
    <br />
    <div class="mb=0">
      <img class="img-circle img-bordered-sm" :src="userImg || defaultImg" alt="user image" style="width:40px;float:left;">
      <div class="message-block">
        <textarea class="form-control"
                  ref="commentMessage"
                  v-model="message"
                  placeholder="Write a comment.."
                  @keyup.self.@="onKeyUp"
                  @keydown.self.up="onKeyUpArrow($event)"
                  @keydown.self.down="onKeyDownArrow($event)"
                  @keydown.self.13="onKeyEnter($event)"
                  >
        </textarea>
        <div class="comment-box-options">
          <el-button size="small" class="comment-box-options-item js-comment-mention-member" @click="openMentionList()" >
            @
          </el-button>
          <el-popover
            ref="mentionList"
            placement="top-start"
            width="300">

            <div class='modal-header clearfix' style="padding:0px;text-align:center;">
              <span>Mention…</span>
              <a class='close pull-right' @click="closeMentionList">&times;</a>
            </div>

            <div class='modal-body mention' style="padding:0px;">
              <ul class='users-list'
                  ref="usersList"
                  @keyup.self.up="onKeyUpArrow"
                  @keyup.self.down="onKeyDownArrow">
                <li  v-for="user in users" @click="mentionUser(user)" @keyup.self.enter="mentionUser(user)">
                  <img :src="user.profileImageUrl" class='profile-image' />
                  {{ user.fullName }}
                </li>
              </ul>
            </div>
          </el-popover>


        </div>
        <br />
        <button class="btn btn-primary" v-on:click="sendMessage">Send</button>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: ['card', 'userImage', 'users'],
    data(){
      return {
        message: '',
        defaultImg: '/images/pp_2.png',
        userImg: this.userImage
      };
    },

    methods: {
      mentionUser(user) {
        let valueMessage = this.$refs.commentMessage.value;
        let textCusrsor = this.$refs.commentMessage.selectionStart;
        let startMsg = valueMessage.substring(0, textCusrsor);
        let endMsg = valueMessage.substring(textCusrsor);
        let startIndex = startMsg.split('').reverse().join('').split(' ')[0].indexOf('@');
        let prefix = '@';
        if (startIndex !== -1) {
          startMsg = startMsg.substring(0, startMsg.length - (startIndex + 1));
        }
        if (startMsg.slice(-1) !== ' ') { prefix = ' ' + prefix; }
        this.$refs.commentMessage.value = [
          startMsg, prefix, user.username, ' ', endMsg
        ].join('');
        this.closeMentionList();
      },
      closeMentionList() {
        this.$refs.mentionList.doClose();
      },
      openMentionList() {
        window.v = this;
        this.$refs.mentionList.doShow();
        this.$refs.usersList.querySelector('li').focus();
      },
      onKeyEnter(event) {
        if (this.$refs.mentionList.showPopper) {
          let currentSelected = this.$refs.usersList.querySelector('li.selected');
          if (currentSelected) { currentSelected.click(); }
          event.preventDefault();
          return false;
        }
      },
      onKeyUpArrow(event) {
        if (this.$refs.mentionList.showPopper) {
          let currentSelected = this.$refs.usersList.querySelector('li.selected');
          if (currentSelected) {
            let nextSelected = currentSelected.previousSibling;
            if (nextSelected) {
              currentSelected.classList.remove('selected');
              nextSelected.classList.add('selected');
            }
          } else {
            currentSelected = this.$refs.usersList.querySelector('li');
            currentSelected.classList.add('selected');
          }

          event.preventDefault();
          return false;
        }
      },
      onKeyDownArrow(event) {
        if (this.$refs.mentionList.showPopper) {
          let currentSelected = this.$refs.usersList.querySelector('li.selected');
          if (currentSelected) {
            let nextSelected = currentSelected.nextSibling;
            if (nextSelected) {
              currentSelected.classList.remove('selected');
              nextSelected.classList.add('selected');
            }
          } else {
            currentSelected = this.$refs.usersList.querySelector('li');
            currentSelected.classList.add('selected');
          }

          event.preventDefault();
          return false;
        }
      },
      onKeyUp(v,n) {
        this.openMentionList();
        let userEl =this.$refs.usersList.querySelector('li');
        if (userEl) { userEl.classList.add('selected'); }
      },
      sendMessage(){
        let url = '/api/v2/company/' + Vue.currentUser.companyId + '/timeline_events';
        this.$http.post(url, {
          timelineEvent: {
            content: this.message,
            eventName: 'comment',
            cardId: this.card.id
          }
        }).then(resp => { this.$emit('eventAddOrUpdate', resp.data.data); });

        this.message = '';
      }
    },
    mounted() { window.v = this; },
    components: {
      'el-button': ElementUi.Button,
      'el-popover': ElementUi.Popover
    }
  };
  </script>
<style lang="sass" >
  .comment-box-options {
    position: absolute;
    bottom: 60px;
    right: 20px;
    border: none;
    width: auto;
    height: 23px;
    background: transparent;
    .mention {
      .profile-image {
        max-width: 20px;
        max-height: 20px;
      }
      ul.users-list {
        max-height: 250px;
        overflow-y: auto;
        li {
          width: 100%;
          float: none;
          text-align: left;
          cursor: pointer;
          padding: 5px 10px;
          border-radius: 0;
          &.selected { background-color: lightblue; }
          &:hover {
            background-color: lightblue;
            }
          &:focus {
            background-color: lightblue;
          }
          &.active {
            background-color: #298FCA;
            color: white;
            }
          }
        }
    }
    .icon-mention {

padding: 6px;
  color: #999;
  height: 18px;
  font-size: 12px;
  line-height: 18px;
  width: 19px;
  }
    .el-button--small.js-comment-mention-member  {
      border: none;
      margin-left: 3px;
      padding: 8px 13px;
      font-size: 12px;
      border-radius: 8px;
      float: right;
      margin-right: 3px;
      }
        .js-comment-mention-member:hover {
          background-color: #f5f7fa;
          }
            }
              </style>
