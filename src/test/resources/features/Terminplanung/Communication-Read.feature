@terminplanung
@optional
@Communication-Read
Feature: Lesen der Ressource Communication (@Communication-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'communication-read-id' hinterlegt sein.

      Legen Sie antwortend auf eine vorherige Nachricht folgende Nachricht in Ihrem System an:
      Status: abgeschlossen
      Patient: Beliebig (Bitte ID in der Konfigurationsvariable 'terminplanung-patient-id' hinterlegen, die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein)
      Sendedatum: Beliebig
      Empfänger: Beliebig (Bitte ID in der Konfigurationsvariable 'terminplanung-practitioner-id' hinterlegen, die verknüpfte Practitioner-Ressource muss konform zu ISiKPersonImGesundheitsberuf sein)
      Sender: Identisch zum angegebenen Patienten
      Inhalt schriftlich: Dies ist eine Testnachricht!
      Zusätzlicher Anhang: text/plain, https://test, beliebig (Typ, Url, Erstellungsdatum)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Communication"

  Scenario: Read einer Nachricht anhand der ID
    Then Get FHIR resource at "http://fhirserver/Communication/${data.communication-read-id}" with content type "xml"
    And resource has ID "${data.communication-read-id}"
    And FHIR current response body is a valid isik3-terminplanung resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKNachricht"
    And TGR current response with attribute "$..status.value" matches "completed"
    And FHIR current response body evaluates the FHIRPath "inResponseTo.exists()" with error message 'Eine Referenz auf die vorherige Nachricht ist nicht vorhanden'
    And element "subject" references resource with ID "${data.terminplanung-patient-id}" with error message "ID der Ressource entspricht nicht der angeforderten ID"
    And FHIR current response body evaluates the FHIRPath "sent.exists()" with error message 'Das Sendedatum ist nicht vorhanden'
    And FHIR current response body evaluates the FHIRPath "recipient.where(display.exists() and reference.replaceMatches('/_history/.+','').matches('\\b${data.terminplanung-practitioner-id}$')).exists()" with error message 'Der Empfänger entspricht nicht dem Erwartungswert oder ist nicht vollständig vorhanden'
    And FHIR current response body evaluates the FHIRPath "sender.where(reference.replaceMatches('/_history/.+','').matches('\\b${data.terminplanung-patient-id}$')).exists()" with error message 'Der Sender entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "payload.where(content.contains('Dies ist eine Testnachricht!')).exists()" with error message 'Der schriftliche Inhalt entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "payload.content.where(contentType = 'text/plain' and url = 'https://test' and creation.exists()).exists()" with error message 'Der zusätzliche Anhang entspricht nicht dem Erwartungswert'
    And element "sender" references resource with ID "${data.terminplanung-patient-id}" with error message "ID des Senders entspricht nicht dem Erwartungswert"
