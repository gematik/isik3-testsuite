@basis
@optional
@Patient-Update-Cancellation
Feature: Update Patient (@Patient-Update-Cancellation)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System KANN intern ein Update auf die Ressource ausführen."
    Given Mit den Vorbedingungen:
      """
        - Legen Sie den folgenden Patienten in Ihrem System an und geben Sie deren ID in der Konfigurationsvariable 'patient-update-cancellation-id' an:

        Status: aktiv
        Vorname: Max
        Nachname: Storno-Update-Mustermann
        Geschlecht: männlich
        Geburtsdatum: 13.5.1968
        Identifier: Beliebig (bitte in den Konfigurationsvariablen 'patient-update-cancellation-identifier-system' und 'patient-update-cancellation-identifier-value' angeben)
      """

  Scenario: Stornierung eines Patienten durch Update
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send PUT request to "http://fhirserver/Patient/${data.patient-update-cancellation-id}" with body "!{file('src/test/resources/features/Basis/fixtures/Patient-Update-Cancellation-Inactive-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR send empty GET request to "http://fhirserver/Patient/${data.patient-update-cancellation-id}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "200"
    And FHIR current response body evaluates the FHIRPath "active = false" with error message 'Der active-Wert entspricht nicht dem Erwartungswert'
