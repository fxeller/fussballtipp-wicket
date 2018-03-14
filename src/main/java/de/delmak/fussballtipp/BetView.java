package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Bet;
import de.delmak.fussballtipp.persistence.Bracket;
import de.delmak.fussballtipp.persistence.Match;
import de.delmak.fussballtipp.persistence.Phase;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Random;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;

@AuthorizeInstantiation("USER")
public class BetView extends BasePage
{

	public static final String BETVIEWMODE_MATCH = "Match";
	public static final String BETVIEWMODE_SPECIAL = "Special";
	
	private Phase phase;

	public final Phase getPhase()
	{
		return phase;
	}

	public final void setPhase(Phase phase)
	{
		this.phase = phase;
	}

	private String viewmode;

	public final String getViewmode()
	{
		return viewmode;
	}

	public final void setViewmode(String viewmode)
	{
		this.viewmode = viewmode;
	}

	private List bets;

	public final List getBets()
	{
		return bets;
	}

	public final void setBets(List bets)
	{
		this.bets = bets;
	}

	public BetView(final PageParameters parameters)
	{
		StringValue paramPhaseId = parameters.get("phaseid");
		if (paramPhaseId.isEmpty() == false)
		{
			setPhase(Phase.getById(paramPhaseId.toInt()));
		}

		StringValue paramViewmode = parameters.get("viewmode");
		if (paramViewmode.isEmpty() == false)
		{
			setViewmode(paramViewmode.toString());
		}
		else
		{
			setViewmode(BETVIEWMODE_MATCH);
		}

		String description = "Undefiniert";

		if (getViewmode().equals(BetView.BETVIEWMODE_MATCH) == true)
		{
			if (getPhase() == null)
			{
				description = "Alle Spiele";
			}
			else
			{
				description = getPhase().getDescription();
			}
		}
		else
		if (getViewmode().equals(BetView.BETVIEWMODE_SPECIAL) == true)
		{
			description = "Sondertipps";
		}
		
		add(new Label("lblDescription", description));
		
		List matches;
		
		if (getPhase() == null)
		{
			matches = Match.getListAll();
		}
		else
		{
			matches = Match.getListByPhaseId(getPhase().getPhaseId());
		}
		
		setBets(Bet.getListByUserId(UserSession.get().getCurrentUser().getUserId()));
		
		WebMarkupContainer pnlMatchBets = new WebMarkupContainer("pnlMatchBets");
		pnlMatchBets.setVisible(getViewmode().equals(BetView.BETVIEWMODE_MATCH) == true);
		add(pnlMatchBets);
		
		Link lnkMatchRandomBet = new Link("lnkMatchRandomBet")
		{
			
			@Override
			public void onClick()
			{
				List matches;

				if (getPhase() == null)
				{
					matches = Match.getListAll();
				}
				else
				{
					matches = Match.getListByPhaseId(getPhase().getPhaseId());
				}
				
				Random randomGenerator = new Random();
				
				for (Object objMatch: matches)
				{
					Match match = (Match) objMatch;
					
					if (match.getIsOpenForBets() == true)
					{
						Bet bet = Bet.getByUserAndBetKindAndMatchId(UserSession.get().getCurrentUser().getUserId(), Bet.BETKIND_MATCH, match.getMatchId());

						if (bet == null)
						{
							Integer scoreHomeRnd = randomGenerator.nextInt(4);
							Integer scoreGuestRnd = randomGenerator.nextInt(4);

							while ((match.getPhase().getIsgroupphase() == false) && (scoreHomeRnd.equals(scoreGuestRnd) == true))
							{
								scoreHomeRnd = randomGenerator.nextInt(4);
								scoreGuestRnd = randomGenerator.nextInt(4);
							}

							bet = new Bet();
							bet.setUser(UserSession.get().getCurrentUser());
							bet.setBetkind(Bet.BETKIND_MATCH);
							bet.setMatchId(match.getMatchId());
							bet.setScoreHome(scoreHomeRnd);
							bet.setScoreGuest(scoreGuestRnd);

							Bet.insert(bet);
						}
					}
				}
				
				setResponsePage(BetView.class, parameters);
			}
		};
		
		pnlMatchBets.add(lnkMatchRandomBet);
		
		ListView rptData = new ListView<Match>("rptData", matches)
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Match match = (Match)item.getModelObject();
					Bet bet = Bet.findByUserAndBetKindAndMatchId(bets, UserSession.get().getCurrentUser(), Bet.BETKIND_MATCH, match.getMatchId());
					String betText = "Nicht getippt";

					if (bet != null)
					{
						betText = String.format("%d - %d", bet.getScoreHome(), bet.getScoreGuest());
					}

					SimpleDateFormat formatterDate = new SimpleDateFormat("dd.MM.yyyy");
					String matchDate = formatterDate.format(match.getDatetime());
										
					SimpleDateFormat formatterTime = new SimpleDateFormat("HH:mm");
					String matchTime = formatterTime.format(match.getDatetime());
					
					String matchResult = "-";
					
					if ((match.getScoreGuest() != null) && (match.getScoreGuest() != null))
					{
						matchResult = String.format("%d:%d", match.getScoreHome(), match.getScoreGuest());
					}
					
					item.add(new Label("fldDate", new Model(matchDate)));
					item.add(new Label("fldTime", new Model(matchTime)));
					item.add(new Label("fldTeamHome", new PropertyModel(match.getTeamHome(), "description")));
					item.add(new Label("fldMatchResult", new Model(matchResult)));
					item.add(new Label("fldTeamGuest", new PropertyModel(match.getTeamGuest(), "description")));
					item.add(new Label("fldBet", new Model(betText)));
					
					PageParameters pageParamsBet = new PageParameters();
					pageParamsBet.set("betkind", Bet.BETKIND_MATCH);
					pageParamsBet.set("matchid", match.getMatchId());
					
					if (getPhase() != null)
					{
						pageParamsBet.set("phaseid", getPhase().getPhaseId());
					}

					BookmarkablePageLink lnkMatchPlaceBet  = new BookmarkablePageLink("lnkMatchPlaceBet", BetPlacing.class, pageParamsBet);
					lnkMatchPlaceBet.setVisible(match.getIsOpenForBets() == true);
					item.add(lnkMatchPlaceBet);

					BookmarkablePageLink lnkMatchShowBet  = new BookmarkablePageLink("lnkMatchShowBet", BetShowing.class, pageParamsBet);
					lnkMatchShowBet.setVisible(match.getIsOpenForBets() == false);
					item.add(lnkMatchShowBet);

					PageParameters pageParamsFinishMatch = new PageParameters();
					pageParamsFinishMatch.set("matchid", match.getMatchId());
					
					if (getPhase() != null)
					{
						pageParamsFinishMatch.set("phaseid", getPhase().getPhaseId());
					}
					
					BookmarkablePageLink lnkFinishMatch = new BookmarkablePageLink("lnkFinishMatch", MatchFinishing.class, pageParamsFinishMatch);
					lnkFinishMatch.setVisible(match.getIsOpenForBets() == false);
					item.add(lnkFinishMatch);
				}
			};
		
		pnlMatchBets.add(rptData);

		WebMarkupContainer pnlSpecialBets = new WebMarkupContainer("pnlSpecialBets");
		pnlSpecialBets.setVisible(getViewmode().equals(BetView.BETVIEWMODE_SPECIAL) == true);
		add(pnlSpecialBets);
		
		ListView<Bracket> rptBracketWinner = new ListView("rptBracketWinner", Bracket.getListAll()) {

			@Override
			protected void populateItem(ListItem item)
			{
				Bracket bracket = (Bracket) item.getModelObject();
				Bet bet = Bet.findByUserAndBetKindAndBracketId(getBets(), UserSession.get().getCurrentUser(), Bet.BETKIND_BRACKETWINNER, bracket.getBracketId());
				String betText = "Nicht getippt";
				
				if (bet != null)
				{
					betText = bet.getTeam().getDescription();
				}
				
				item.add(new Label("lblBracketWinner", new Model("Sieger ".concat(bracket.getDescription()))));
				item.add(new Label("lblBracketWinnerBet", new Model(betText)));

				PageParameters pageParamsBet = new PageParameters();
				pageParamsBet.set("betkind", Bet.BETKIND_BRACKETWINNER);
				pageParamsBet.set("bracketid", bracket.getBracketId());

				BookmarkablePageLink lnkBracketWinnerPlaceBet = new BookmarkablePageLink("lnkBracketWinnerPlaceBet", BetPlacing.class, pageParamsBet);
				lnkBracketWinnerPlaceBet.setVisible(bracket.getIsOpenForBets() == true);
				item.add(lnkBracketWinnerPlaceBet);
				
				BookmarkablePageLink lnkBracketWinnerShowBet = new BookmarkablePageLink("lnkBracketWinnerShowBet", BetShowing.class, pageParamsBet);
				lnkBracketWinnerShowBet.setVisible(bracket.getIsOpenForBets() == false);
				item.add(lnkBracketWinnerShowBet);
			}
		};
		
		pnlSpecialBets.add(rptBracketWinner);

		Bet bet = Bet.findByUserAndBetKind(getBets(), UserSession.get().getCurrentUser(), Bet.BETKIND_CHAMPION);
		String betText = "Nicht getippt";
		
		if (bet != null)
		{
			betText = bet.getTeam().getDescription();
		}

		pnlSpecialBets.add(new Label("lblChampionBet", new Model(betText)));

		PageParameters pageParamsBet = new PageParameters();
		pageParamsBet.set("betkind", Bet.BETKIND_CHAMPION);

		BookmarkablePageLink lnkChampionPlaceBet = new BookmarkablePageLink("lnkChampionPlaceBet", BetPlacing.class, pageParamsBet);
		lnkChampionPlaceBet.setVisible(Phase.getByName("Achtel").getIsOpenForBets() == true);
		pnlSpecialBets.add(lnkChampionPlaceBet);
		
		BookmarkablePageLink lnkChampionShowBet = new BookmarkablePageLink("lnkChampionShowBet", BetShowing.class, pageParamsBet);
		lnkChampionShowBet.setVisible(Phase.getByName("Achtel").getIsOpenForBets() == false);
		pnlSpecialBets.add(lnkChampionShowBet);
	}
}
