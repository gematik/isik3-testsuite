@basis
@mandatory
@Composition-Post
Feature: POST eines Document-Bundles (@Composition-Post)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die in der Composition hinterlegten Patienten und Encounter mittels Identifier auflösen können."
    Given Mit den Vorbedingungen:
      """
       - Der Testfall Encounter-Read-In-Progress muss zuvor erfolgreich ausgeführt worden sein.
      """

  Scenario: POST eines DocumentBundles mit bekannten Patienten und Encounter
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send POST request to "http://fhirserver/" with body "!{file('src/test/resources/features/Basis/fixtures/Composition-Post-CorrectCompositionBundle.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "20\d"

  Scenario Outline: POST eines inkorrekten DocumentBundles mit <variation>
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send POST request to "http://fhirserver/" with body "!{file('src/test/resources/features/Basis/fixtures/<inputFile>')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "<responseCode>"
    And FHIR current response body evaluates the FHIRPath "issue.where(severity = 'error' or 'fatal').count() >= 1" with error message 'Das OperationOutcome enthält nicht den/die geforderten Issues'

    Examples:
      | variation             |  inputFile                                                 | responseCode |
      | unbekanntem Patienten |  Composition-Post-CompositionBundleUnknownPatient.json     |    422       |
      | unbekanntem Encounter |  Composition-Post-CompositionBundleUnknownEncounter.json   |    422       |
      | ohne Narrative        |  Composition-Post-CompositionBundleMissingText.json        |    4\d\d     |