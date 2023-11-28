@basis
@mandatory
@Composition-Post
Feature: POST eines Document-Bundles (@Composition-Post)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die in der Composition hinterlegten Patienten und Encounter mittels Identifier auflösen können."
    Given Mit den Vorbedingungen:
      """
       - Der Testfall Patient-Read & Encounter-Read müssen zuvor erfolgreich ausgeführt worden sein.
      """

  Scenario: POST eines DocumentBundles mit bekannten Patienten und Encounter
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send POST request to "http://fhirserver/Composition" with multiline body:
      """
        {
          "resourceType": "Composition",
          "id": "example",
          "identifier": {
            "system": "http://healthintersections.com.au/test",
            "value": "1"
          },
          "subject": {
            "reference": "Patient/xcda",
            "display": "Henry Levin the 7th"
          },
          "encounter": {
            "reference": "Encounter/xcda"
          },
          "date": "2012-01-04T09:10:14Z",
          "author": [
            {
              "reference": "Practitioner/xcda-author",
              "display": "Harold Hippocrates, MD"
            }
          ]
        }
      """
    Then TGR find last request to path "/Composition/" with "$.path._id.value" matching "${data.codesystem-read-id}"
