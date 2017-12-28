<template>
  <ul class="nav nav-pills nav-stacked">
    <li :class="[{active: activeItem('profile')}]">
      <router-link :to="profileUrl">
        <i class="fa fa-edit"></i> Profile
      </router-link>
    </li>

    <li :class="[{active: activeItem('companies')}]">
      <router-link :to="companiesUrl">
        <i class="fa fa-edit"></i> Companies
      </router-link>
    </li>
    <li :class="[{active: activeItem('team')}]">
      <router-link :to="teamUrl">
        <i class="fa fa-edit"></i>Team
      </router-link>
    </li>

    <li :class="[{active: activeItem('integration')}]">
      <router-link :to="integrationUrl">
      <i class="fa fa-edit"></i>
      Integration
      </router-link>
    </li>
    <li :class="[{active: activeItem('import')}]">
      <a :href="importUrl">
      <i class="fa fa-edit"></i>
      Import
      </a>
    </li>
</ul>

</template>
<script>
  export default {
    data() { return {
      urlPrefix: '/company/' + Vue.currentUser.companyId
    }; },
    computed: {
      profileUrl() { return this.urlPrefix + '/settings/profile'; },
      companiesUrl() { return this.urlPrefix + '/settings/companies'; },
      teamUrl() { return this.urlPrefix + '/settings/team_edit'; },
      integrationUrl() { return this.urlPrefix + '/settings/api_key'; },
      importUrl() { return this.urlPrefix + '/import'; }
    },
    methods: {
      activeItem(item) {
        if (this.$route.name === 'profilePage' && item === 'profile') {
          return true;
        }
        if (this.$route.name === 'settings-companies' && item === 'companies') {
          return true;
        }
        if (this.$route.name === 'settings-new-company' && item === 'companies') {
          return true;
        }
        if (this.$route.name === 'settings-edit-company' && item === 'companies') {
          return true;
        }
        if (this.$route.name === 'settings-team-edit' && item === 'team') {
          return true;
        }

        if (this.$route.name === 'settings-api-key' && item === 'integration') {
          return true;
        }
        if (this.$route.name === 'contacts-import' && item === 'import') {
          return true;
        }

      }
    }
  };
</script>
<style lang="sass">

</style>
