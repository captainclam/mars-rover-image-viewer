API_URL = 'https://api.nasa.gov/mars-photos/api/v1/'
API_KEY = 'wwYXJBLASfX4wNrbLfEetDdx6U3EbRSm1Lx93DGa'

module.exports = [
  '$http'
  ($http) ->
    getPhotos: (filter) ->
      return $http(
        method: 'GET'
        url: API_URL + 'rovers/' + filter.rover.toLowerCase() + '/photos' + '?camera=' + filter.camera + '&earth_date=' + moment(filter.date).format('YYYY-M-D')  + '&api_key=' + (API_KEY or 'DEMO_KEY')
      )
    getManifest: (rover) ->
      return $http(
        method: 'GET'
        url: API_URL + 'manifests/' + rover.toLowerCase() + '?api_key=' + (API_KEY or 'DEMO_KEY')
      ).then ({data}) ->
        return data.photo_manifest
]