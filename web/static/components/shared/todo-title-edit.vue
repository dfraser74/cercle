<template>
  <div v-on-click-outside='cancel'>
    <div class="readonly-text" v-on:click="setEditMode" v-show="!editMode" v-html="compiledMarkdown">
    </div>

    <div v-show="editMode">
      <div class="form-group">
        <textarea type='text'
                  v-model='v' class='form-control'
                  :placeholder='placeholder'
                  v-on:keydown.enter.stop="save"
                  v-on:keyup.esc.stop="cancel"
                  ref='input' v-autosize="rawText" rows="1" />
      </div>
      <div>
        <el-button type="success" size="mini" @click='save'>Save</el-button>
        <el-button type="danger" size="mini" @click.stop='remove' class="pull-right" icon="el-icon-delete"></el-button>
        <el-button type="text" size="mini" @click.stop='cancel'>Cancel</el-button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: ['value', 'placeholder'],
  data() {
    return {
      editMode: false,
      v: this.value
    };
  },
  watch: {
    'value': function() {
      this.v = this.value;
    }
  },
  computed: {
    compiledMarkdown() {
      if (this.v)
        return (new MarkdownIt({breaks:true, linkify: true})).render(this.v);
      return  this.placeholder;
    }
  },
  methods: {
    setEditMode(event) {
      if(event.target.className.match(/\blinkified\b/))
        return;

      this.editMode = true;
      var vue = this;
      Vue.nextTick(function () {
        vue.$refs.input.focus();
      });
    },
    save() {
      this.$emit('input', this.v);
      this.editMode = false;
    },
    cancel() {
      this.v = this.value;
      this.editMode = false;
    },
    remove() {
      this.$emit('remove');
    }
  }
};
</script>
