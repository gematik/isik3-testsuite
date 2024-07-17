@dokumentenaustausch
@terminplanung
@optional
@Binary-Read-Raw
Feature: Lesen der Ressource Binary im nativen Format (@Binary-Read-Raw)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die Binary-Ressource bei einem HTTP GET auf deren URL und einem nicht FHIR-Accept-Header, die Ressource im nativen Format korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Binary-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read von Binärdaten im nativen Format anhand der ID
    When TGR send empty GET request to "http://fhirserver/Binary/${data.binary-read-id}" with headers:
        | Accept | text/plain |
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR current response with attribute "$.header.Content-Type" matches "text/plain"
    And TGR current response with attribute "$.body" matches "Test"
