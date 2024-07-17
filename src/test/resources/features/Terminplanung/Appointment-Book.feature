@terminplanung
@mandatory
@Appointment-Book
Feature: Buchung eines Termins (@Appointment-Book)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS Buchung von Terminen unterstützen."
    Given Mit den Vorbedingungen:
    """
      - Ein freier Terminblock mit Startzeit 1.9.2024 09:00 und Endzeit 1.9.2024 20:00 muss zuvor manuell im System im beliebigen Kalender angelegt worden sein (bitte die Terminblock-ID in der Konfigurationsvariable 'appointment-book-slot-id' hinterlegt)
      - Servicetyp: beliebig (bitte in den Konfigurationsvariablen 'appointment-book-servicetype-system' und 'appointment-book-servicetype-code' hinterlegen)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Given Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains operation "book" for resource "Appointment"

  Scenario: Buchung eines Termins anhand eines freien Terminblocks
    Given TGR set default header "Content-Type" to "application/fhir+json"
    And TGR send POST request to "http://fhirserver/Appointment/$book" with body "!{file('src/test/resources/features/Terminplanung/fixtures/Appointment-Appointment-Book-Fixture.json')}"
    Then TGR find the last request
    And TGR current response with attribute "$.responseCode" matches "20\d"
    #  Asserts for the case if the response is an Appointment
    And FHIR current response body evaluates the FHIRPath '($this is Appointment) or ($this is Parameters)' with error message 'Rückgabe enthält weder eine Appointment noch eine OperationOutcome-Ressource noch eine Parameters-Ressource'
    And FHIR current response body evaluates the FHIRPath '($this is Appointment) implies id.exists()' with error message 'Rückgabevariante Appointment: Dem Termin wurde keine ID zugewiesen'
    And FHIR current response body evaluates the FHIRPath "($this is Appointment) implies status.toString().matches('^booked|pending$')" with error message 'Rückgabevariante Appointment: Dem Termin wurde keine ID zugewiesen'
    #  Asserts for the case if the response is a Parameters-Ressource
    And FHIR current response body evaluates the FHIRPath "($this is Parameters) implies parameter.where(name = 'return' and resource is Appointment).resource.id.exists()" with error message 'Rückgabevariante Parameters: Dem Termin wurde keine ID zugewiesen'
    And FHIR current response body evaluates the FHIRPath "($this is Parameters) implies parameter.where(name = 'return' and resource is Appointment).resource.status.toString().matches('^booked|pending$')" with error message 'Rückgabevariante Parameters: Status des Termins ist weder booked noch pending'

  Scenario: Buchung eines Termins falls die Terminanfrage unvollständig ist (keine Angaben zum Terminblock bzw. zu einem Kalender)
    Given TGR set default header "Content-Type" to "application/fhir+json"
    And TGR send POST request to "http://fhirserver/Appointment/$book" with body "!{file('src/test/resources/features/Terminplanung/fixtures/Appointment-Appointment-Book-Incomplete-Fixture.json')}"
    Then TGR find the last request
    And TGR current response with attribute "$.responseCode" matches "400"
    And FHIR current response body evaluates the FHIRPath '$this is OperationOutcome' with error message 'Rückgabe enthält keine OperationOutcome-Ressource'