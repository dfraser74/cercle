<template>
  <div class="new-contact" style="padding: 10px;">
    <div class="form-group">
      <v-select v-model="name"
                :debounce="250"
                :on-change="selectContact"
                :on-search="searchContacts"
                :options="contacts"
                :taggable="true"
                placeholder="Full Name"
                label="name"><span slot="no-options"></span></v-select>
    </div>
    <div class="form-group">
      <input type="email" v-model="email" placeholder="Email" class="form-control" :disabled="existingContactId!=null" />
    </div>
    <div class="form-group">
      <input type="phone" v-model="phone" placeholder="Phone" class="form-control" :disabled="existingContactId!=null" />
    </div>
    <div class="form-group" v-show="defaultBoardId==null">
      <label>
        <input type="checkbox" v-model="addToBoard" value="true" :disabled="existingContactId!=null" />
        Add to board
      </label>
    </div>
    <div class="form-group" v-show="defaultBoardId==null">
      <select v-model="boardId" class="form-control" :disabled="addToBoard!=true" v-on:change="loadColumns">
        <option v-for="board in boards" :value="board.id">{{ board.name }}</option>
      </select>
    </div>
    <div class="form-group">
      <select v-model="columnId" class="form-control" :disabled="addToBoard!=true">
        <option v-for="col in columns" :value="col.id">{{ col.name }}</option>
      </select>
    </div>
    <div class="form-group">
      <button class="btn btn-success" v-on:click="saveContact">Save</button>
      <a class="btn btn-link" @click="cancel">Cancel</a>
    </div>
  </div>
</template>

<script>
export default {
  props: ['userId', 'companyId', 'boards', 'defaultBoardId'],
  data: function() {
    return {
      name: null,
      email: null,
      phone: null,
      columnId: null,
      columns: [],
      boardId: this.defaultBoardId,
      addToBoard: true,
      existingContactId: null,
      contacts: []
    };
  },
  components: {
    'v-select': vSelect.VueSelect
  },
  methods: {
    loadColumns: function() {
      let board = this.boards.filter( (b)  => {
        return b.id === parseInt(this.boardId);
      })[0];

      if (board)
        this.columns = board.board_columns;
      if (this.columns.length)
        this.columnId = this.columns[0].id;
    },

    addContactToBoard: function(userId, companyId, contactId, boardId, columnId) {
      let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/card/';
      this.$http.post(url,{
        card: {
          contactIds: [contactId],
          userId: userId,
          companyId: companyId,
          boardId: boardId,
          boardColumnId: columnId,
          name: ''
        }
      }).then ( _ => { window.location.href='/board/'+boardId; });
    },

    saveContact: function(){
      let vu = this;
      let userId = this.userId;
      let companyId = this.companyId;
      let boardId = this.boardId;
      let columnId = this.columnId;

      if(this.existingContactId) {
        this.addContactToBoard(userId, companyId, this.existingContactId, boardId, columnId);
      } else if(this.name) {
        var addToBoard = this.addToBoard;
        let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/contact';
        this.$http.post(url,{
          contact: {
            userId: userId,
            companyId: companyId,
            name: this.name,
            email: this.email,
            phone: this.phone
          }
        }).then( resp => {
          if(addToBoard) {
            vu.addContactToBoard(userId, companyId, resp.data.data.id, boardId, columnId);
          } else {
            window.location.href='/contact';
          }
        });
      }
    },

    cancel: function() {
      this.$emit('close');
    },

    selectContact(con) {
      if(typeof con!=='string') {
        this.existingContactId = con.id;
        this.email = con.email;
        this.phone = con.phone;
        this.addToBoard = true;
      } else {
        this.existingContactId = null;
        this.name = con;
        this.email = null;
        this.phone = null;
      }
    },

    searchContacts(search, loading) {
      loading(true);
      this.$http.get('/api/v2/company/'+ Vue.currentUser.companyId +'/contact', { params: { q: search }}).then(resp => {
        this.contacts = resp.data.data;
        loading(false);
      });
    }
  },
  mounted: function() {
    this.loadColumns();
  }
};
</script>
