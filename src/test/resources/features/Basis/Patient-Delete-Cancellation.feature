@basis
@optional
@Patient-Delete-Cancellation
Feature: Delete Patient (@Patient-Delete-Cancellation)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System KANN ein Delete auf die Ressource ausführen."
    Given Mit den Vorbedingungen:
      """
        - Legen Sie einen beliebigen Patienten in Ihrem System an und geben Sie die ID der Ressource in der Konfigurationsvariable 'patient-delete-id' an
      """

  Scenario: Stornierung eines Patienten durch Delete
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send empty DELETE request to "http://fhirserver/Patient/${data.patient-delete-id}"
    And TGR find the last request
    # Ignore content-type header, as it may be missing for 4** responses
    Then TGR current response with attribute "$.responseCode" matches "20\d"
    And TGR send empty GET request to "http://fhirserver/Patient/${data.patient-delete-id}"
    And TGR find the last request
    # Ignore content-type header, as it may be missing for 4** responses
    Then TGR current response with attribute "$.responseCode" matches "410|404"
